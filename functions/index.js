const { createHash } = require('node:crypto');
const { initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');

const { isRealPriceDrop } = require('./price_drop');

initializeApp();

exports.notifyPriceDrop = onDocumentUpdated(
  { document: 'merchandise/{productId}', region: 'asia-south1' },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!isRealPriceDrop(before, after)) return;

    const database = getFirestore();
    const productId = event.params.productId;
    const eventKey = createHash('sha256')
      .update(`${productId}:${event.id}`)
      .digest('hex')
      .slice(0, 32);
    const title = `Price drop: ${after.name || 'Wishlisted product'}`;
    const message = `Now PKR ${after.price}. Previous price: PKR ${before.price}.`;
    let cursor = null;
    let notified = 0;

    do {
      let query = database
        .collectionGroup('wishlist')
        .where('productId', '==', productId)
        .limit(200);
      if (cursor) query = query.startAfter(cursor);
      const page = await query.get();
      if (page.empty) break;

      for (const wish of page.docs) {
        const userId = wish.ref.parent.parent?.id;
        if (!userId) continue;
        const user = await database.collection('users').doc(userId).get();
        const profile = user.data();
        if (
          !profile ||
          profile.role !== 'fan' ||
          profile.accountStatus === 'disabled' ||
          profile.priceDropNotifications !== true
        ) {
          continue;
        }

        const notification = database
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(`price_${eventKey}`);
        try {
          await notification.create({
            type: 'price_drop',
            productId,
            title,
            message,
            oldPrice: before.price,
            newPrice: after.price,
            read: false,
            createdAt: FieldValue.serverTimestamp(),
          });
        } catch (error) {
          if (error.code === 6 || error.code === 'already-exists') continue;
          throw error;
        }
        notified++;

        const devices = await database
          .collection('users')
          .doc(userId)
          .collection('devices')
          .where('enabled', '==', true)
          .limit(10)
          .get();
        const eligible = devices.docs.filter(
          (device) => typeof device.data().token === 'string',
        );
        if (eligible.length === 0) continue;
        try {
          const result = await getMessaging().sendEachForMulticast({
            tokens: eligible.map((device) => device.data().token),
            notification: { title, body: message },
            data: { type: 'price_drop', productId },
          });
          await Promise.all(
            result.responses.map((response, index) => {
              const code = response.error?.code;
              if (
                code === 'messaging/invalid-registration-token' ||
                code === 'messaging/registration-token-not-registered'
              ) {
                return eligible[index].ref.delete();
              }
              if (!response.success) {
                logger.warn('Price-drop push failed', {
                  userId,
                  productId,
                  code,
                });
              }
              return Promise.resolve();
            }),
          );
        } catch (error) {
          logger.error('Price-drop push dispatch failed', {
            userId,
            productId,
            error: error.message,
          });
        }
      }
      cursor = page.docs[page.docs.length - 1];
      if (page.size < 200) break;
    } while (cursor);

    logger.info('Price-drop event processed', { productId, notified });
  },
);
