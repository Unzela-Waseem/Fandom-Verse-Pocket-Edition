# Fandom Verse Project Access Guide

This file is safe to keep in GitHub. It contains public project identifiers,
links, and credential locations. **Do not put passwords, API secrets, service
account JSON files, or private keys in this document or in Git.**

## Core links

| Service | Link |
| --- | --- |
| GitHub repository | https://github.com/Unzela-Waseem/Fandom-Verse-Pocket-Edition |
| Firebase project | https://console.firebase.google.com/project/fandom-verse-pocket-unzela/overview |
| Firebase Authentication | https://console.firebase.google.com/project/fandom-verse-pocket-unzela/authentication |
| Firestore database | https://console.firebase.google.com/project/fandom-verse-pocket-unzela/firestore |
| Firestore rules | https://console.firebase.google.com/project/fandom-verse-pocket-unzela/firestore/rules |
| Cloudinary dashboard | https://console.cloudinary.com/console/home |
| Google AI Studio | https://aistudio.google.com/app/apikey |

## Public project identifiers

| Item | Value |
| --- | --- |
| Firebase project ID | `fandom-verse-pocket-unzela` |
| Firebase plan | Spark (free) |
| Cloudinary cloud name | `dc1w5stzg` |
| Flutter application version | `1.0.0+1` |
| Android application ID / namespace | `com.fandomverse.fandom_verse_pocket` |
| Android minimum SDK | 24 (Android 7.0) |
| Android compile / target SDK | 36 |
| Android Java / JVM target | Java 17 |
| Android Firebase app ID | `1:477827303954:android:4652141a5302461dcc26cb` |
| iOS Firebase app ID | `1:477827303954:ios:f3f08ccadd961be5cc26cb` |
| Web Firebase app ID | `1:477827303954:web:d31180872a196600cc26cb` |

The client Firebase configuration is in `lib/firebase_options.dart` and
`android/app/google-services.json`. Firebase client API keys identify the
Firebase project; they are not administrator credentials. Security is enforced
by Firebase Authentication, Firestore rules, and server-side secrets.

## Private credentials — keep outside GitHub

| Credential | Secure location / action |
| --- | --- |
| Gemini API key | Set locally in `functions/.env` or as Firebase secret: `firebase functions:secrets:set GEMINI_API_KEY` |
| Cloudinary API key and API secret | Keep only in the private `CLOUDINARY_URL` environment variable on the media backend: `cloudinary://API_KEY:API_SECRET@dc1w5stzg` |
| Firebase service-account JSON | Keep outside the repository; use Application Default Credentials or a hosting secret manager |
| Admin password | Choose and store privately in a password manager; never commit it |
| Upload preset names | Configure privately on the Cloudinary account and set them as backend environment variables |

Files named `.env`, `functions/.env`, `*-service-account.json`, and
`admin-tools/key.json` are ignored by Git. Use `.env.example` only as a
template—do not put a real secret in it.

## Accounts and role access

- **Fan:** create through the in-app Email/Password registration flow, or use
  Google/Apple after those providers are configured.
- **Admin:** provision through `admin-tools/` using Firebase Admin credentials.
  An admin must have both the Firebase custom claim and Firestore role set by
  the protected provisioning script. Do not create an admin by editing client
  code or Firestore from an untrusted account.

### Admin sign-in details

There is no safe universal live Admin password to publish. A real Admin account
is created privately by the project owner. Save its login in a password manager,
not in this repository.

| Field | Where to get or set it |
| --- | --- |
| Admin email | Private project-owner record or the `FANDOM_ADMIN_EMAIL` value used during provisioning |
| Admin password | Private password manager or local ignored environment only; never put it in Markdown/GitHub |
| Admin display name | Optional `FANDOM_ADMIN_NAME` value during provisioning |
| Admin role | Created by `admin-tools/provision-admin.mjs`; it writes the Firestore `role: admin` and trusted Firebase custom claim |

For a new administrator, an owner with Firebase Admin access runs this from a
private terminal:

```bash
cd admin-tools
npm ci
FANDOM_ADMIN_EMAIL='admin@example.com' \
FANDOM_ADMIN_PASSWORD='use-a-private-12-plus-character-password' \
FANDOM_ADMIN_NAME='Fandom Verse Admin' \
npm run provision-admin
```

The values above are examples only. Replace them locally; do not copy a real
password into this file. A sample evaluation identity may be documented in the
repository README, but it must not be used as a real production administrator.

## Run the project from a fresh clone

### 1. Install prerequisites

Install these tools before opening the project:

| Tool | Required version / purpose |
| --- | --- |
| Flutter | Flutter 3.44.7 or a compatible Flutter 3.x release |
| Dart | Included with Flutter (project currently uses Dart 3.12.2) |
| Android Studio | Android SDK, platform tools, and Java/Gradle support for Android builds |
| Google Chrome | Local Web development and testing |
| Firebase CLI | Firebase rules, indexes, secrets, and function deployment |
| Node.js 22+ | Only needed for `functions/`, `media-backend/`, and admin scripts |

Verify the local toolchain:

```bash
flutter doctor
flutter --version
firebase --version
node --version
```

### 2. Clone and install packages

```bash
git clone https://github.com/Unzela-Waseem/Fandom-Verse-Pocket-Edition.git
cd Fandom-Verse-Pocket-Edition
flutter pub get
```

Do **not** copy another person's `.env`, Cloudinary secret, Firebase service
account, or Gemini key into Git. Create your own local private environment
files from `.env.example` where needed.

### 3. Confirm Firebase configuration

The Android, iOS, and Web Firebase applications are already registered for
`fandom-verse-pocket-unzela`.

```bash
firebase login
firebase use fandom-verse-pocket-unzela
firebase deploy --only firestore:rules,firestore:indexes \
  --project fandom-verse-pocket-unzela
```

In the Firebase console, ensure these sign-in providers are enabled:

- Email/Password — required for Fan registration.
- Google — required only when Google sign-in is used.
- Apple — requires an Apple Developer account and Firebase Apple provider
  configuration before it can work on Apple devices.

### 4. Run in Chrome (Web)

```bash
flutter run -d chrome
```

For a stable local Web URL:

```bash
flutter run -d chrome --web-port=7357
```

If Google Web sign-in is enabled, add the local host (for example,
`localhost`) to Firebase Authentication → Settings → Authorized domains.

### 5. Run on Android / Redmi

1. Enable **Developer options** and **USB debugging** on the Android phone.
2. Connect it using a USB data cable and accept the debugging prompt.
3. Check that Flutter can see it:

```bash
flutter devices
```

4. Run the app using the Android device ID shown by the previous command:

```bash
flutter run -d <ANDROID_DEVICE_ID>
```

### 6. Use the prebuilt release APK

The latest locally generated APK is:

`build/app/outputs/flutter-apk/app-release.apk`

Copy it to the Redmi, open it from the phone's file manager, allow installs
from that source if Android asks, and select **Install**. If Android refuses
an update because a previously installed version was signed with a different
certificate, uninstall that old app first, then install the new APK.

## Testing and quality checks

Run focused tests while developing a feature:

```bash
flutter test test/auth_error_test.dart test/registration_screen_test.dart
flutter test test/ar_preview_test.dart
flutter test test/quote_recognizer_service_test.dart
```

Run static analysis:

```bash
flutter analyze
```

Run all tests:

```bash
flutter test
```

Some legacy layout tests currently require cleanup because their fixture does
not initialize Firebase and some assertions reference older bundled sample
content. Do not treat a passing build alone as device-level verification.

## Key project commands

```bash
# Run in Chrome for local development
flutter run -d chrome

# Run on a connected Android device
flutter run -d <ANDROID_DEVICE_ID>

# Publish Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes \
  --project fandom-verse-pocket-unzela

# Create a private Gemini secret before deploying the AI function
firebase functions:secrets:set GEMINI_API_KEY
firebase deploy --only functions:askFanHelper \
  --project fandom-verse-pocket-unzela
```

## Build a release APK safely on a low-memory laptop

The project already limits Gradle to one worker and a restricted heap in
`android/gradle.properties`. Keep other heavy applications closed during the
build, then run:

```bash
flutter build apk --release
```

The APK output is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Do not rename or move an older APK over a new build. The filename stays
`app-release.apk`, so every new release build overwrites the previous output.

> The current Android release configuration uses the debug signing key for
> local/sideloaded testing. Before Google Play publishing, create a private
> upload/signing key and configure the release signing process. Never commit a
> keystore or its passwords.

## Firebase data and roles

| Area | Collection / location | Who can manage it |
| --- | --- | --- |
| User profiles | `users/{uid}` | The owner may edit permitted profile fields; admin has protected access |
| Content | `content` | Admin |
| Events | `events` | Admin |
| Merchandise | `merchandise` | Admin |
| Discussions | `discussions` | Signed-in fans create their own; admin moderates |
| Inquiries | `users/{uid}/inquiries` | Fan creates own inquiry; admin triages |
| Audit log | `audit_logs` | Admin only |

The Firestore rules source is `firebase/firestore.rules`. After changing it,
deploy it using the Firebase command above. Never relax rules merely to make a
client-side error disappear.

## Cloudinary media setup

The app is configured to use Cloudinary cloud `dc1w5stzg` for images and
videos. The Flutter client never contains the Cloudinary API secret.

1. Open the Cloudinary dashboard and create signed upload presets for avatars,
   images, and videos.
2. On a trusted HTTPS Node.js host, deploy `media-backend/`.
3. Set private backend variables: `CLOUDINARY_URL`, the upload-preset names,
   Firebase service-account/ADC access, and exact `ALLOWED_WEB_ORIGINS`.
4. Configure the app's media-backend URL in its private local environment.
5. Test an admin image/video upload and a fan avatar upload. Confirm returned
   media uses `https://res.cloudinary.com/dc1w5stzg/`.

Detailed instructions are in `docs/CLOUDINARY_SPARK.md`.

## AI Fan Helper setup

1. Create a Gemini API key in Google AI Studio.
2. Store it as a Firebase secret; never put it in Flutter code:

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

3. Deploy the callable function (requires Firebase plan/features available for
   Functions in the project):

```bash
firebase deploy --only functions:askFanHelper \
  --project fandom-verse-pocket-unzela
```

Without the deployed server function, the app safely uses its curated offline
AI-helper fallback instead of exposing a Gemini key.

## Feature-specific test notes

- **Authentication:** create a Fan account, sign out, sign in as Admin, sign
  out, and sign in again as the Fan. The Fan dashboard should load after a
  short spinner.
- **AR / 3D:** choose a Store item with **View AR**. First confirm the 3D
  model appears and rotates. Real camera AR requires an ARCore-supported
  Android device, Google Play Services, camera permission, and a well-lit
  flat surface. Chrome only tests the 3D preview, not camera placement.
- **Quote Match:** type a supported quote or character name. Matching happens
  locally and needs no AI key. The Store must contain related product keywords
  for a matching product search to show useful results.
- **Checkout:** it is simulated only; no card or payment details are collected.
- **Price-drop alerts:** on the Spark plan, the app can show local in-app
  alerts while it is running; background cloud push delivery needs paid/cloud
  infrastructure.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| App shows old code in Chrome | In the `flutter run` terminal press `R` for hot restart, or stop and rerun `flutter run -d chrome`. |
| Fan profile access error after account switch | Sign out, hot restart, then sign in again. Confirm deployed Firestore rules match `firebase/firestore.rules`. |
| Android 3D model does not load | Confirm the product has a valid HTTPS `.glb` model URL and install the latest APK. |
| Camera AR option does not appear | Update Google Play Services for AR; the phone may not be ARCore compatible. 3D preview can still work. |
| Google sign-in fails on Web | Enable Google provider and add the actual local/production domain in Firebase authorized domains. |
| Cloudinary upload fails | Check the deployed media backend, signed preset, HTTPS URL, server secret, and allowed Web origin. |
| AI Helper only gives offline replies | Configure the Gemini secret and deploy the `askFanHelper` function. |

## Related setup guides

- Cloudinary media setup: `docs/CLOUDINARY_SPARK.md`
- Web setup: `docs/WEB.md`
- Notifications: `docs/NOTIFICATIONS.md`
- Development notes: `DEVELOPMENT.md`
- Admin provisioning: `README.md` and `admin-tools/`

## Before sharing the repository

1. Run `git status --ignored` and confirm no `.env`, service-account file, or
   Cloudinary credential is staged.
2. If any secret was ever committed, revoke/rotate it in its provider console.
3. Give collaborators Firebase/Cloudinary access through each provider's
   account-permission system, not by sending passwords or key files.
