# Cloudinary media on Firebase Spark

The Flutter app uses Cloudinary cloud `dc1w5stzg` for public avatars, editorial images, and content videos. Firebase Authentication and Firestore remain on the Spark plan. No Firebase Storage or Cloud Functions deployment is required. In-app uploads require the separate Node service in `media-backend/`; Cloudinary credentials must never be embedded in Flutter or committed to Git.

## What the code does

- A signed-in Fan can upload a profile image (JPEG, PNG, or WebP; at most 5 MB). A signed-in Admin with the `admin` custom claim and Admin profile role can upload content images/videos, event images, and merchandise images (images at most 10 MB; MP4/MOV/WebM videos at most 100 MB).
- Flutter checks the selected file's extension, signature, and size, asks the backend for a short-lived signed ticket, uploads directly to Cloudinary with progress/cancel support, then sends Cloudinary's response proof to the backend.
- The backend verifies the Firebase ID token, account status, role, Cloudinary response signature, asset path, type, format, size, and the canonical asset returned by the Cloudinary Admin API. Only then does it update a Fan's Firestore avatar or return an editorial URL to the Admin form. After an avatar replacement, it attempts to remove the previous avatar owned by that Fan. It also limits signature requests per account per UTC day.
- Cloudinary folders are created by the first upload under `fandom-verse/avatars/<owner-hash>`, `fandom-verse/content/images`, `fandom-verse/content/videos`, `fandom-verse/events/images`, or `fandom-verse/merchandise/images`. Cloudinary's public delivery URLs are not suitable for private media.
- Admins can still paste an existing HTTPS media URL into the form. The in-app upload buttons appear only in Android/iOS builds with a valid signer URL.

The size caps above are application limits, not a guarantee that the Cloudinary account permits every file. Large-video chunked/resumable upload is not implemented. Replaced editorial images/videos are not deleted automatically because other records may still reference them; review those assets in Cloudinary before removing them.

## Account setup for your own testing

1. In the Cloudinary console for `dc1w5stzg`, create three **signed** upload presets with simple names containing letters, numbers, underscores, or hyphens. Set permitted formats and maximum file sizes:

   | Preset environment variable | Formats | Maximum size |
   | --- | --- | --- |
   | `CLOUDINARY_AVATAR_PRESET` | `jpg,png,webp` | 5 MB |
   | `CLOUDINARY_IMAGE_PRESET` | `jpg,png,webp` | 10 MB |
   | `CLOUDINARY_VIDEO_PRESET` | `mp4,mov,webm` | 100 MB |

   The backend also signs the allowed formats and rejects oversized assets after upload. Configure limits in the Cloudinary presets too, so Cloudinary rejects invalid files before storing them.

2. Deploy `media-backend/` to an HTTPS Node.js 22+ host outside Firebase Cloud Functions. Set these private server environment variables: `CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@dc1w5stzg`, the three preset names above, and `GOOGLE_APPLICATION_CREDENTIALS` pointing to a Firebase service-account JSON available only on that server (or configure Application Default Credentials using the host's secret manager). Never share the API secret or service-account JSON in chat or add them to Git. The service listens on `PORT` (default `8080`) and exposes `GET /health`, `POST /media/sign`, and `POST /media/complete`.

3. When you are ready to run the mobile app, pass the public backend URL at build/run time, for example `--dart-define=CLOUDINARY_SIGNER_URL=https://your-media-host.example`. This is a public URL, not a secret. The app hides upload buttons if the value is missing or is not HTTPS. Android/iOS access to that URL and Cloudinary must work from the device.

4. Deploy `firebase/firestore.rules` before testing avatar uploads: the owner-editable `avatarUrl` field has been removed so only the trusted backend can update it. The Admin custom claim still has to be assigned separately before Admin uploads work. Existing profile creation, including a social provider photo URL, remains supported.

5. Test a Fan avatar and an Admin content image/video, event image, and merchandise image. Confirm that the returned URL uses `https://res.cloudinary.com/dc1w5stzg/`, the relevant Firestore data updates, and the media renders in the app. Test a non-Admin upload attempt, an unsupported format, an oversized file, and cancellation. This repository does not include a live-account test or deployed media host.

## Trusted-computer fallback

An Admin can upload from a trusted computer using `admin-tools/upload-media.mjs` and paste its `secureUrl` into the form. The script now rejects any `CLOUDINARY_URL` that does not point to `dc1w5stzg`:

```bash
node --env-file=.env admin-tools/upload-media.mjs path/to/image.png
```

The private `.env` file is ignored by Git. This fallback accepts JPEG/PNG/WebP up to 5 MB and MP4/MOV/WebM up to 100 MB. It does not implement resumable large-video uploads.

## Current handoff boundary

The upload logic is implemented and locally checked, but the owner has not connected the `dc1w5stzg` credentials/presets or deployed the HTTPS media backend. Without those steps, in-app uploads remain unavailable. No APK has been built.
