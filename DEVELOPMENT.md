# Development Notes

## Current phase

Core Fan flows are implemented and verified. Work is continuing on cloud-backed catalog synchronization, privileged Admin CRUD, notifications, and provider integrations.

## Decisions

- Flutter 3.44.7 / Dart 3.12.2; Android minimum SDK 28 (Android 9).
- Riverpod is the single state-management approach and Material 3 is the UI foundation.
- Admin registration is not exposed. Authorization must fail closed and be enforced by Firebase rules plus trusted backend operations.
- Checkout is simulated and will never collect payment-card data.
- AI provider secrets will only be used by a trusted backend; the client will provide curated FAQ fallback behavior.

## External prerequisites

- The owner chose Firebase Spark with Cloudinary media, so do not enable billing or Firebase Storage. The prepared Storage avatar code remains disabled. Signed in-app Cloudinary uploads need a separate trusted signer; trusted-computer Admin uploads are available without billing.
- An owner must provision the first Admin using `admin-tools/provision-admin.mjs` with service-account Application Default Credentials and an owner-selected email/password. The mobile client cannot create or promote Admins.
- Google/Apple sign-in provider configuration and native device verification. The code is present but neither provider is enabled in this Firebase project.
- Google Maps API keys restricted per platform.
- FCM and trusted serverless functions for price-drop notifications and privileged user administration.
- Billing/permissions for scheduled Firestore exports.

## Verification log

- 2026-09-23: `flutter analyze` completed with no issues.
- 2026-09-23: Four unit/widget tests passed.
- 2026-09-23: Added an original dark gaming-inspired responsive UI and local multiverse artwork. The preview shell is explicitly non-authenticated; it does not represent completed Firebase functionality.
- 2026-09-23: Created Firebase project `fandom-verse-pocket-unzela`, registered Android/iOS apps, created Firestore in `asia-south1` with deletion protection, enabled email/password Authentication, and deployed Firestore rules.
- 2026-09-23: Added real Firebase initialization, Fan registration/profile creation, login, password reset, session-aware AuthGate, trusted role loading, and fail-closed recovery states. Analyzer and five tests pass.
- 2026-09-23: Added working content search/category filters/details, persistent offline bookmarks, saved event agendas, city-filtered event details, validated HTTPS ticket/map links, merchandise search/filter/price sort, persistent wishlist/cart, simulated checkout, bills, and local purchase history. Analyzer passes and seven tests pass.
- 2026-09-23: Added offline curated AI Fan Helper, Firestore-backed discussions with author edit/delete controls, secure persisted inquiries, About Us, saved/offline views, wishlist/order counters, purchase history, and sign-out access. Strengthened and deployed inquiry/discussion ownership rules.
- 2026-09-23: Added Firestore-backed profile editing plus contextual location permission, nearby-event sorting, city fallback, and explicit denied/permanently-denied/unavailable states. Analyzer passes and all seven tests pass.
- 2026-09-23: Replaced Admin placeholders with Firestore editors for categories, content, events, merchandise, and announcements; added user status management, discussion moderation, inquiry triage, and atomic audit events. Deployed role/status enforcement and the inquiry collection group index. Analyzer and seven existing tests pass; Admin device and authorization integration tests remain pending.
- 2026-09-23: Connected Fan content, events, products, saved lists, and cart to live Firestore records while keeping bundled preview content. Local saved state is isolated by Firebase account. Bookmarked content and saved event details now persist as full offline snapshots. Analyzer passes and eight tests pass; cross-device synchronization remains pending.
- 2026-09-23: Removed inert home controls and fabricated live popularity counts. Home category/story navigation and bookmarking now use real catalog records; added an in-app announcement and personal notification center with read state. Published-announcement access rules were released to Firestore. FCM delivery and price-drop generation remain pending.
- 2026-09-23: Added Admin user profile editing, disable confirmation, stricter catalog validation, and safer delete error handling. Firestore Admin access now requires both an active Admin profile and a trusted custom claim; the rule compiled and deployed successfully. Removed an unverified office-visit claim from Contact Us while awaiting actual team contact details. Analyzer and eight tests pass.
- 2026-09-23: Added Firestore user-subcollection mirroring for bookmarks, saved events, wishlist, cart, and simulated orders with one-time local migration, account-switch guards, cache-aware listeners, and a visible sync failure state. Saved article text survives a tested local restart. Rules for saved events deployed; analyzer and nine tests pass. Two-device conflict and offline reconnection tests remain pending.
- 2026-09-23: Prepared a Firestore merchandise price-drop trigger with duplicate-resistant in-app notifications and best-effort FCM dispatch, plus explicit Fan permission/opt-in and device token registration. The Node price comparison test passes, the function loads locally, Flutter analysis and nine tests pass, and supporting Firestore rules/indexes are deployed. Function deployment is blocked by the project's unbilled plan; no push delivery is claimed.
- Device, Firebase emulator, and integration verification remain pending until platform configuration is available.
- 2026-09-23: Added gated native Google/Apple Fan sign-in flows. First-time provider accounts create a default Fan profile; existing account roles are never rewritten, and incomplete sign-in fails closed. Labeled bundled sample events and removed their placeholder ticket/map actions. Static analysis and unit/widget tests pass; provider sign-in needs owner configuration and a real device test.
- 2026-09-23: Prepared an owner-path avatar upload with file-signature MIME checks, a 5 MB limit, progress/cancel UI, and old-avatar cleanup. Image selection is hidden until Storage is provisioned; Storage rules are updated locally but are not deployed without a bucket. Static checks and 16 tests pass; upload itself remains unverified.
- 2026-09-23: Reconfirmed the active Firebase project and deployed email/password Authentication plus Firestore rules and indexes on Spark. Added the Android Internet permission, remote content/event/merchandise images, online content video playback, and a trusted-computer signed Cloudinary upload tool. Cloudinary account claim and real media tests remain pending.

## Provider sign-in activation

Provider buttons are hidden by default. Enable them only after completing the native Firebase setup and device verification; never add OAuth secrets or a service-account file to Git.

1. For Google, enable the Google provider in Firebase Authentication, register the signing certificate SHA-1 fingerprints for Android debug and release keys, then refresh the Android Firebase configuration. For iOS, complete the Google Sign-In plugin's client ID and URL-scheme setup in the native project.
2. For Apple, configure Sign in with Apple in the Apple Developer account and Firebase Authentication, and add the Sign in with Apple capability to the iOS Runner target.
3. Run the app with `--dart-define=ENABLE_GOOGLE_SIGN_IN=true` and/or `--dart-define=ENABLE_APPLE_SIGN_IN=true` only for providers that are configured. Apple is shown on iOS only. Confirm first-time Fan profile creation, repeat sign-in, existing Admin role preservation, cancellation, and account switching on a real device before release.

## Avatar upload activation

The owner chose Spark and Cloudinary instead of Firebase Storage. Do not enable `ENABLE_AVATAR_UPLOAD` or deploy Storage rules on this route. The prepared Firebase Storage avatar flow is superseded; a Cloudinary avatar uploader needs a separate trusted signing backend. See [Cloudinary setup](docs/CLOUDINARY_SPARK.md).
