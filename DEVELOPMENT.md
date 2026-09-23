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

- Cloud Storage provisioning requires a billing-enabled Firebase plan for new projects. Storage rules are ready but cannot be deployed until billing is enabled.
- Google/Apple sign-in provider configuration.
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
- Device, Firebase emulator, and integration verification remain pending until platform configuration is available.
