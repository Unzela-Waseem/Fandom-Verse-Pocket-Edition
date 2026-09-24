# Web development and limitations

The existing Firebase Web app `1:477827303954:web:d31180872a196600cc26cb` is configured in `lib/firebase_options.dart`. Email/password Fan registration and sign-in, Firestore catalog/community/admin data, local saved state, and responsive navigation use the same Flutter code as mobile. The Web app has not been published to a public host.

## Run locally

From the repository root:

```bash
flutter pub get
flutter run -d chrome --web-port=7357
```

Open the local address printed by Flutter. To test Cloudinary upload after the HTTPS media backend and signed presets are deployed, add `--dart-define=CLOUDINARY_SIGNER_URL=https://your-media-host.example` and allow `http://localhost:7357` in the backend's `ALLOWED_WEB_ORIGINS`. See [Cloudinary setup](CLOUDINARY_SPARK.md).

## Before public release

- Deploy the Flutter Web output to an HTTPS host and add that exact origin to `ALLOWED_WEB_ORIGINS` if uploads are enabled. Add any production domain needed for Firebase Authentication under Firebase Console → Authentication → Settings → Authorized domains. `localhost` is currently authorized only for development; review/remove it before a production release.
- Browser push notifications are not configured: there is no Web Push VAPID key or Firebase Messaging service worker. The in-app notification center remains available; the Web UI does not request a browser push token.
- Email/password and Google sign-in are enabled in Firebase; Google Web uses a browser popup and must be acceptance-tested with a real account on the intended origin. If popups are blocked, allow them for the app. Apple remains hidden until its provider is configured in Apple Developer and Firebase; then run with `--dart-define=ENABLE_APPLE_SIGN_IN=true`.
- Test the app in the intended browsers and screen sizes, plus a real account against the production Firebase project. The Chrome build and local automated checks do not substitute for that acceptance test.
