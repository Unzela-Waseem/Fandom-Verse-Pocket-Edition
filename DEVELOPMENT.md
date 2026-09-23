# Development Notes

## Current phase

The repository foundation is in progress. Firebase platform files are intentionally not committed until a Firebase project is selected and configured with `flutterfire configure`.

## Decisions

- Flutter 3.44.7 / Dart 3.12.2; Android minimum SDK 28 (Android 9).
- Riverpod is the single state-management approach and Material 3 is the UI foundation.
- Admin registration is not exposed. Authorization must fail closed and be enforced by Firebase rules plus trusted backend operations.
- Checkout is simulated and will never collect payment-card data.
- AI provider secrets will only be used by a trusted backend; the client will provide curated FAQ fallback behavior.

## External prerequisites

- Firebase project registration and generated platform configuration.
- Google/Apple sign-in provider configuration.
- Google Maps API keys restricted per platform.
- FCM and trusted serverless functions for price-drop notifications and privileged user administration.
- Billing/permissions for scheduled Firestore exports.

## Verification log

- 2026-09-23: `flutter analyze` completed with no issues.
- 2026-09-23: Four unit/widget tests passed.
- 2026-09-23: Added an original dark gaming-inspired responsive UI and local multiverse artwork. The preview shell is explicitly non-authenticated; it does not represent completed Firebase functionality.
- Device, Firebase emulator, and integration verification remain pending until platform configuration is available.
