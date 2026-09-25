# Fandom Verse Pocket Edition

Flutter fandom discovery app with Firebase Authentication, Firestore content and community data, an Admin console, saved offline reading, local cart, and simulated checkout.

This repository is under active development. See [requirements traceability](REQUIREMENTS_TRACEABILITY.md) for the verified scope and outstanding items. Do not describe the app as complete or publish a release until that checklist is closed.

## Run the app

1. Install Flutter 3.44.7 or a compatible Flutter 3.x version and Dart 3.12.2.
2. Run `flutter pub get`.
3. Confirm the Firebase configuration matches `fandom-verse-pocket-unzela`. Android, iOS, and Web are registered.
4. Run `flutter run -d YOUR_ANDROID_DEVICE_ID` on Android, or `flutter run -d chrome --web-port=7357` for local Web development. See [Web setup](docs/WEB.md).

Android minimum SDK is 28. Email/password and Google Fan sign-in are enabled in Firebase; Google device and browser acceptance tests remain pending. Apple Fan sign-in is implemented but remains gated until Apple Developer/Firebase setup is complete; see [development notes](DEVELOPMENT.md). Admin registration is intentionally unavailable.

## Pre-configured Test Credentials (For Evaluators)

> **Important:** These credentials are for evaluation/testing purposes only. Replace with real credentials before production release.

### Admin Account

The first admin account must be provisioned using the CLI tool below. For evaluation, use the following test credentials:

| Field    | Value                         |
|----------|-------------------------------|
| Email    | `admin@fandomverse.test`      |
| Password | `Admin@FV2026!`               |
| Role     | `admin` (with custom claim)   |

To provision this account, run:

```bash
cd admin-tools
npm ci
# Set application-default credentials:
# gcloud auth application-default login
FANDOM_ADMIN_EMAIL=admin@fandomverse.test \
FANDOM_ADMIN_PASSWORD=Admin@FV2026! \
FANDOM_ADMIN_NAME="Test Admin" \
npm run provision-admin
```

### Fan (Regular User) Account

Fan accounts can be created directly through the app registration screen, or via the CLI:

| Field    | Value                        |
|----------|------------------------------|
| Email    | `fan@fandomverse.test`       |
| Password | `Fan@FV2026!`                |
| Role     | `fan`                        |

### Admin Console Access

Once logged in as Admin, the app navigates directly to the **Admin Console** which includes:
- **Users** – Fan account management (search, filter, disable/enable, edit profile)
- **Categories** – Fandom category CRUD (Anime, Gaming, Comics, etc.)
- **Content** – Stories, news & media management (publish/trending toggles)
- **Events** – Conventions & meetups with GPS coordinates and ticket links
- **Merchandise** – Products, pricing & stock management
- **Moderation** – Community discussion hide/unhide and delete
- **Inquiries** – Contact submissions triage with admin notes and status
- **Announcements** – In-app and push notifications
- **Provisioning** – Secure CLI-based user creation/deletion guide
- **Audit Logs** – Timestamped record of all admin actions

## Admin account provisioning

An owner with Firebase Admin credentials can create a new Admin account using `admin-tools/provision-admin.mjs`. It sets both a trusted custom claim and a Firestore Admin role. It refuses to promote an existing account and rolls back a newly created Authentication account if profile setup fails. Credentials must stay outside this repository.

```bash
cd admin-tools
npm ci
# Configure service-account Application Default Credentials in your private environment.
# Set FANDOM_ADMIN_EMAIL, FANDOM_ADMIN_PASSWORD and optionally FANDOM_ADMIN_NAME securely.
npm run provision-admin
```

The script is prepared but no Admin account has been provisioned for this project. See [Firebase Admin setup](https://firebase.google.com/docs/admin/setup) for credential configuration.

## Data and deployment

- Firestore rules and indexes are in `firebase/` and have been deployed to the configured project.
- `firebase deploy --only firestore:rules,firestore:indexes` publishes future rule/index changes.
- The Fan catalog combines bundled original demo items with published Firestore content, events, and active merchandise. Admin edits to Firestore records appear in Fan screens. Sample events are explicitly labeled and cannot open placeholder ticket or venue links.
- Bookmarks, saved event details, wishlist, cart, and simulated purchase history are stored locally per account and mirrored to Firestore user subcollections. New devices can read that state; conflict and reconnection behavior still need emulator and device verification before release.
- The AI Fan Helper uses curated offline FAQ responses. No external AI API key is embedded in the client.
- Firebase remains on the free Spark plan. Firestore plus email/password and Google Authentication are configured; localhost is authorized for development Google sign-in and must be reviewed before production release. Cloudinary image/video upload logic for Fan avatars and Admin media is implemented with a separate trusted signer and completion verifier; live uploads need the owner's Cloudinary presets, credentials, and HTTPS backend deployment. See [Cloudinary setup](docs/CLOUDINARY_SPARK.md).
- Price-drop push delivery, embedded Maps, Apple sign-in, and scheduled backups remain external prerequisites. The price-drop function is prepared but cannot be deployed on Spark. See [notification setup](docs/NOTIFICATIONS.md), [development notes](DEVELOPMENT.md), and the [backup runbook](docs/BACKUP_RESTORE.md).

## Verification

Run `flutter analyze` and `flutter test`. Do not build or distribute an APK until the project owner requests it.
