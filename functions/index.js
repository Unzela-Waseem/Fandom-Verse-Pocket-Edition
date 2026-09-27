/**
 * Fandom Verse — Cloud Functions
 *
 * Exports:
 *   notifyPriceDrop  – Firestore trigger: notifies wishlisting fans of a real price drop.
 *   provisionUser    – HTTPS callable: creates a Firebase Auth user + Firestore profile.
 *                      Only callable by a verified admin (admin custom claim required).
 *   deleteAuthUser   – HTTPS callable: deletes a Firebase Auth user + Firestore profile.
 *                      Only callable by a verified admin.
 *
 * Security model:
 *   Both provisionUser and deleteAuthUser check context.auth.token.admin === true.
 *   This custom claim is set during admin account creation (provision-admin.mjs).
 *   A regular fan can NEVER call these functions successfully even if they try directly.
 */

'use strict';

const { createHash } = require('node:crypto');
const { initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const OpenAI = require('openai');

const { isRealPriceDrop } = require('./price_drop');

initializeApp();

const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');

exports.askFanHelper = onCall(
  {
    region: 'asia-south1',
    enforceAppCheck: false,
    secrets: [OPENAI_API_KEY],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Please sign in to use AI Fan Helper.');
    }

    const message = request.data?.message;
    if (typeof message !== 'string' || message.trim().length === 0) {
      throw new HttpsError('invalid-argument', 'A question is required.');
    }
    if (message.length > 2000) {
      throw new HttpsError('invalid-argument', 'Questions must be 2,000 characters or fewer.');
    }

    const client = new OpenAI({ apiKey: OPENAI_API_KEY.value() });
    try {
      const response = await client.responses.create({
        model: 'gpt-5',
        store: false,
        max_output_tokens: 500,
        instructions: [
          'You are AI Fan Helper inside Fandom Verse Pocket Edition.',
          'Answer the user helpfully and naturally in the language they use.',
          'You can answer general questions as well as fandom, anime, games, cosplay, events, merchandise, and app questions.',
          'Do not claim access to private account data, live event availability, or real-time information unless it is supplied in the conversation.',
          'Keep answers concise and friendly. For medical, legal, financial, or safety emergencies, encourage appropriate professional or emergency help.',
        ].join(' '),
        input: message.trim(),
      });
      const answer = response.output_text?.trim();
      if (!answer) {
        throw new Error('OpenAI returned no text output.');
      }
      return { answer };
    } catch (error) {
      logger.error('askFanHelper failed', {
        code: error?.code,
        status: error?.status,
        requestId: error?._request_id,
      });
      throw new HttpsError(
        'internal',
        'AI Fan Helper is temporarily unavailable. Please try again shortly.',
      );
    }
  },
);

// ─── Helper: assert caller is an authenticated Admin ──────────────────────────

function assertAdmin(auth) {
  if (!auth) {
    throw new HttpsError('unauthenticated', 'You must be signed in.');
  }
  if (auth.token.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'Only admins can perform this action.',
    );
  }
}

async function assertActiveAdminProfile(auth) {
  assertAdmin(auth);
  const profile = await getFirestore().collection('users').doc(auth.uid).get();
  if (!profile.exists || profile.data()?.role !== 'admin' ||
      profile.data()?.accountStatus !== 'active') {
    throw new HttpsError('permission-denied', 'Your admin profile is not active.');
  }
}

// ─── provisionUser ─────────────────────────────────────────────────────────────
// Creates a Firebase Auth user + matching Firestore profile.
// Fan accounts get role=fan; admin accounts also get the admin custom claim.
//
// Request data: { displayName, email, password, role }
// Response:     { uid }

exports.provisionUser = onCall(
  { region: 'asia-south1', enforceAppCheck: false },
  async (request) => {
    await assertActiveAdminProfile(request.auth);

    const { displayName, email, password, role } = request.data ?? {};

    // ── Validate inputs ──────────────────────────────────────────────────────
    if (
      typeof displayName !== 'string' ||
      displayName.trim().length < 1 ||
      displayName.trim().length > 60
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Display name must be 1–60 characters.',
      );
    }
    if (typeof email !== 'string' || !email.includes('@')) {
      throw new HttpsError('invalid-argument', 'A valid email is required.');
    }
    const isAdmin = role === 'admin';
    const minPasswordLength = isAdmin ? 12 : 8;
    if (
      typeof password !== 'string' ||
      password.length < minPasswordLength
    ) {
      throw new HttpsError(
        'invalid-argument',
        `Password must be at least ${minPasswordLength} characters.`,
      );
    }
    if (role !== 'fan' && role !== 'admin') {
      throw new HttpsError(
        'invalid-argument',
        'Role must be "fan" or "admin".',
      );
    }

    // ── Check email is not already taken ────────────────────────────────────
    const auth = getAuth();
    const existing = await auth
      .getUserByEmail(email.trim().toLowerCase())
      .catch((e) => (e.code === 'auth/user-not-found' ? null : Promise.reject(e)));
    if (existing) {
      throw new HttpsError(
        'already-exists',
        `Email ${email} is already registered.`,
      );
    }

    // ── Create Firebase Auth account ─────────────────────────────────────────
    const user = await auth.createUser({
      email: email.trim().toLowerCase(),
      password,
      displayName: displayName.trim(),
      emailVerified: false,
      disabled: false,
    });

    // ── Set admin custom claim if needed ────────────────────────────────────
    if (isAdmin) {
      await auth.setCustomUserClaims(user.uid, { admin: true });
    }

    // ── Create Firestore profile (rollback Auth user on failure) ────────────
    const db = getFirestore();
    try {
      await db.collection('users').doc(user.uid).create({
        uid: user.uid,
        displayName: displayName.trim(),
        email: email.trim().toLowerCase(),
        bio: '',
        avatarUrl: null,
        selectedFandoms: [],
        badge: isAdmin ? 'Admin' : 'New Explorer',
        role,
        accountStatus: 'active',
        priceDropNotifications: false,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        createdBy: request.auth.uid,
      });

      // ── Audit log ────────────────────────────────────────────────────────
      await db.collection('audit_logs').add({
        actorId: request.auth.uid,
        actorEmail: request.auth.token.email ?? 'unknown',
        action: 'provision-user',
        collection: 'users',
        recordId: user.uid,
        detail: { role, email: user.email },
        createdAt: FieldValue.serverTimestamp(),
      });
    } catch (err) {
      // Rollback: remove the Auth account so we don't leave a dangling credential
      await auth.deleteUser(user.uid).catch(() => {});
      logger.error('provisionUser Firestore write failed, Auth rolled back', {
        uid: user.uid,
        err: err.message,
      });
      throw new HttpsError(
        'internal',
        'Profile creation failed. The Auth account was rolled back.',
      );
    }

    logger.info('provisionUser success', { uid: user.uid, role });
    return { uid: user.uid };
  },
);

// ─── deleteAuthUser ────────────────────────────────────────────────────────────
// Deletes a Firebase Auth user AND their Firestore profile.
// Refuses to delete admin accounts for safety.
//
// Request data: { uid }
// Response:     { deleted: true }

exports.deleteAuthUser = onCall(
  { region: 'asia-south1', enforceAppCheck: false },
  async (request) => {
    await assertActiveAdminProfile(request.auth);

    const { uid } = request.data ?? {};
    if (typeof uid !== 'string' || uid.trim().length === 0) {
      throw new HttpsError('invalid-argument', 'uid is required.');
    }
    // Prevent self-deletion
    if (uid === request.auth.uid) {
      throw new HttpsError(
        'failed-precondition',
        'You cannot delete your own account.',
      );
    }

    const db = getFirestore();
    const profile = await db.collection('users').doc(uid).get();

    // Safety: refuse to delete admin accounts via this path
    if (profile.exists && profile.data()?.role === 'admin') {
      throw new HttpsError(
        'failed-precondition',
        'Cannot delete an admin account. Demote to fan first.',
      );
    }

    // ── Audit log BEFORE deletion so there is a paper trail ─────────────────
    await db.collection('audit_logs').add({
      actorId: request.auth.uid,
      actorEmail: request.auth.token.email ?? 'unknown',
      action: 'delete-user',
      collection: 'users',
      recordId: uid,
      detail: { email: profile.data()?.email ?? 'unknown' },
      createdAt: FieldValue.serverTimestamp(),
    });

    // ── Delete Firestore profile ─────────────────────────────────────────────
    if (profile.exists) {
      await db.collection('users').doc(uid).delete();
    }

    // ── Delete Firebase Auth account ─────────────────────────────────────────
    const auth = getAuth();
    await auth.deleteUser(uid);

    logger.info('deleteAuthUser success', { uid });
    return { deleted: true };
  },
);

// ─── setUserStatus ────────────────────────────────────────────────────────────
// Keeps Firebase Auth and the profile status aligned. This is deliberately a
// trusted operation: a client-side Firestore update alone would leave an Auth
// credential usable outside the application.
exports.setUserStatus = onCall(
  { region: 'asia-south1', enforceAppCheck: false },
  async (request) => {
    await assertActiveAdminProfile(request.auth);
    const { uid, enabled } = request.data ?? {};
    if (typeof uid !== 'string' || uid.trim().length === 0 ||
        typeof enabled !== 'boolean') {
      throw new HttpsError('invalid-argument', 'uid and enabled are required.');
    }
    if (uid === request.auth.uid) {
      throw new HttpsError(
        'failed-precondition',
        'You cannot change your own admin account status.',
      );
    }

    const db = getFirestore();
    const profileRef = db.collection('users').doc(uid);
    const profile = await profileRef.get();
    if (!profile.exists) {
      throw new HttpsError('not-found', 'User profile was not found.');
    }
    if (profile.data()?.role === 'admin') {
      throw new HttpsError(
        'failed-precondition',
        'Admin account status must be changed through the trusted CLI.',
      );
    }

    const auth = getAuth();
    const authUser = await auth.getUser(uid);
    await auth.updateUser(uid, { disabled: !enabled });
    try {
      await db.runTransaction(async (transaction) => {
        transaction.update(profileRef, {
          accountStatus: enabled ? 'active' : 'disabled',
          updatedAt: FieldValue.serverTimestamp(),
          updatedBy: request.auth.uid,
        });
        transaction.set(db.collection('audit_logs').doc(), {
          actorId: request.auth.uid,
          actorEmail: request.auth.token.email ?? 'unknown',
          action: enabled ? 'enable-user' : 'disable-user',
          collection: 'users',
          recordId: uid,
          createdAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      await auth.updateUser(uid, { disabled: authUser.disabled }).catch(() => {});
      throw error;
    }
    return { enabled };
  },
);

// ─── notifyPriceDrop ───────────────────────────────────────────────────────────

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
