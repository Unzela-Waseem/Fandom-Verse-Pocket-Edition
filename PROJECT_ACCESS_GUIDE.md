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
| Android application ID | `com.fandomverse.fandomVersePocket` |
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
