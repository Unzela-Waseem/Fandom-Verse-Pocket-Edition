# Cloudinary media with Firebase Spark

Firebase project `fandom-verse-pocket-unzela` remains on the free Spark plan. Firebase Authentication and Firestore are live. Cloudinary is the intended host for images and videos; Firebase Storage is not required for this route.

## Current working path

1. Upload an approved image or video from a trusted computer using the private `CLOUDINARY_URL` credential. This repository includes `admin-tools/upload-media.mjs`, which checks the media signature and size, performs a signed upload, and prints only the HTTPS delivery URL and public ID. Never run it in the mobile app or commit `.env`.
2. In the app's Admin Console, paste the returned `secureUrl` into an item's image or video URL field and publish it. Content, event, and merchandise images render in the Fan app; content videos play in-app when online.
3. Keep the returned `publicId` in the editorial asset record for later replacement or deletion. Do not use Cloudinary public delivery for private user content.

From the repository root:

```bash
node --env-file=.env admin-tools/upload-media.mjs assets/images/fandom_multiverse.png
```

The private `.env` must contain `CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME`. The image limit in the trusted script is 5 MB; video limit is 100 MB. These are application limits, not a promise about the Cloudinary plan. Large-video resumable upload is not implemented.

## What Spark cannot provide by itself

An upload from a public mobile app must not contain the Cloudinary API secret. A signed in-app upload needs an online trusted signer that checks the Firebase ID token and authorizes the asset path and media type. Cloud Functions for Firebase cannot be deployed on Spark. An unsigned upload preset would be accessible to anyone who learns its name and could consume the media quota; it is intentionally not enabled for Fan avatars or Admin in-app uploads.

Until a separate trusted no-card backend is connected, Fan avatar upload remains disabled and Admin media is uploaded from the trusted computer. The earlier Firebase Storage avatar implementation is also disabled and must not be enabled on this Spark/Cloudinary route.

## Account ownership

An agent-provisioned Claimable Cloud must be claimed by the project owner within the 24-hour window shown by Cloudinary. If not claimed, the environment and its assets expire. Do not publish its delivery URLs in production before the claim is complete. Cloudinary API secrets stay local and are never checked into Git.
