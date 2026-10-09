# Price-drop notification setup

Status: prepared, **not deployed**. The current Firebase project does not have billing enabled. Cloud Functions deployment requires the Blaze plan, so no price-drop trigger or push delivery is active yet. The Fan app supports explicit opt-in and device token registration, and Firestore rules/indexes for that data are deployed.

## Behavior after activation

- An Admin reduces the numeric `price` of an active Firestore merchandise record.
- `notifyPriceDrop` checks that the new price is lower than the previous price.
- It queries only users who wishlisted that product, then checks each user's active Fan status and `priceDropNotifications == true` preference.
- It creates one deterministic, user-owned in-app notification per price-change event. Repeated delivery of the same event does not create duplicates.
- It sends push to registered enabled devices and removes invalid or expired tokens. A push failure does not remove the in-app notification.

## Activation and verification

1. The project owner enables billing and configures an appropriate budget alert.
2. Configure Android Firebase Cloud Messaging and, if iOS delivery is required, APNs capabilities and credentials. Keep signing keys out of Git.
3. In `functions/`, run `npm ci` and `npm test`.
4. Deploy only the function with `firebase deploy --only functions:notifyPriceDrop --project fandom-verse-pocket-unzela`.
5. Sign in as a Fan on a real device, opt into price-drop alerts, wishlist a test product, and verify that a device record appears under the Fan's `devices` subcollection.
6. As a provisioned Admin, lower that product's actual `price`. Verify one unread in-app notification and one device push. Repeat the same update event or retry the function and confirm no duplicate notification. Test a Fan without the wishlist and a Fan with opt-out; neither should receive one.
7. Test denied notification permission, invalid token cleanup, offline reconnection, and foreground/background delivery before calling push complete.

The function source is in `functions/index.js`; price-change validation is covered by `functions/price_drop.test.js`. Its production trigger and push delivery cannot be tested or claimed active until billing and device setup are complete.

Official references: [Cloud Functions setup](https://firebase.google.com/docs/functions/get-started), [Firestore triggers](https://firebase.google.com/docs/functions/firestore-events), [FCM Admin SDK](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk).
