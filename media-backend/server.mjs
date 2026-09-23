import { createServer } from 'node:http';
import { createHash, randomUUID } from 'node:crypto';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import {
  CLOUD_NAME, credentialsFromEnvironment, mediaPolicy,
  signParameters, validAsset, validPublicId, validResponseSignature,
} from './cloudinary.mjs';

const credentials = credentialsFromEnvironment();
const presets = {
  avatar: process.env.CLOUDINARY_AVATAR_PRESET,
  image: process.env.CLOUDINARY_IMAGE_PRESET,
  video: process.env.CLOUDINARY_VIDEO_PRESET,
};
for (const purpose of ['avatar', 'contentImage', 'contentVideo']) {
  mediaPolicy(purpose, 'startup-check', presets);
}
initializeApp({ credential: applicationDefault(), projectId: 'fandom-verse-pocket-unzela' });
const auth = getAuth();
const db = getFirestore();

function reply(response, status, data) {
  response.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
    'x-content-type-options': 'nosniff',
  });
  response.end(JSON.stringify(data));
}

async function readJson(request) {
  if (!request.headers['content-type']?.startsWith('application/json')) {
    throw Object.assign(new Error('Send JSON.'), { status: 415 });
  }
  let body = '';
  for await (const chunk of request) {
    body += chunk;
    if (body.length > 4096) throw Object.assign(new Error('Request is too large.'), { status: 413 });
  }
  try {
    const parsed = JSON.parse(body);
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error();
    return parsed;
  } catch {
    throw Object.assign(new Error('Invalid JSON.'), { status: 400 });
  }
}

async function authenticated(request) {
  const match = /^Bearer ([A-Za-z0-9._-]+)$/.exec(request.headers.authorization ?? '');
  if (!match) throw Object.assign(new Error('Sign in first.'), { status: 401 });
  let decoded;
  try {
    decoded = await auth.verifyIdToken(match[1], true);
  } catch {
    throw Object.assign(new Error('Your session expired. Sign in again.'), { status: 401 });
  }
  const snapshot = await db.collection('users').doc(decoded.uid).get();
  const profile = snapshot.data();
  if (!profile || profile.accountStatus !== 'active') {
    throw Object.assign(new Error('This account cannot upload media.'), { status: 403 });
  }
  return { decoded, profile };
}

function authorize(purpose, actor) {
  if (purpose === 'avatar') return;
  if (actor.profile.role !== 'admin' || actor.decoded.admin !== true) {
    throw Object.assign(new Error('Admin access is required.'), { status: 403 });
  }
}

async function enforceLimit(uid, purpose) {
  const day = new Date().toISOString().slice(0, 10);
  const owner = createHash('sha256').update(uid).digest('hex').slice(0, 32);
  const reference = db.collection('media_upload_limits').doc(`${owner}_${day}`);
  const field = purpose === 'avatar' ? 'avatars' : 'editorial';
  const limit = field === 'avatars' ? 10 : 50;
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const count = snapshot.get(field) ?? 0;
    if (count >= limit) {
      throw Object.assign(new Error('Daily upload limit reached.'), { status: 429 });
    }
    transaction.set(reference, { [field]: count + 1, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
  });
}

async function fetchAsset(policy, publicId) {
  const path = `/${policy.resourceType}/upload/${encodeURIComponent(publicId)}`;
  const endpoint = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/resources${path}`;
  const authorization = Buffer.from(`${credentials.apiKey}:${credentials.apiSecret}`).toString('base64');
  const response = await fetch(endpoint, { headers: { authorization: `Basic ${authorization}` }, signal: AbortSignal.timeout(15000) });
  if (!response.ok) throw Object.assign(new Error('Uploaded media could not be confirmed.'), { status: 502 });
  return response.json();
}

async function deleteOldAvatar(publicId) {
  const endpoint = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/destroy`;
  const authorization = Buffer.from(`${credentials.apiKey}:${credentials.apiSecret}`).toString('base64');
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      authorization: `Basic ${authorization}`,
      'content-type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({ public_id: publicId, invalidate: 'true' }),
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error('Cloudinary could not remove the old avatar.');
}

async function sign(request, response) {
  const actor = await authenticated(request);
  const body = await readJson(request);
  const purpose = body.purpose;
  if (typeof purpose !== 'string') throw Object.assign(new Error('Invalid media purpose.'), { status: 400 });
  let policy;
  try { policy = mediaPolicy(purpose, actor.decoded.uid, presets); }
  catch { throw Object.assign(new Error('Invalid media purpose.'), { status: 400 }); }
  authorize(purpose, actor);
  await enforceLimit(actor.decoded.uid, purpose);
  const timestamp = Math.floor(Date.now() / 1000);
  const publicId = randomUUID();
  const parameters = {
    allowed_formats: policy.allowedFormats,
    folder: policy.folder,
    overwrite: 'false',
    public_id: publicId,
    timestamp,
    upload_preset: policy.preset,
  };
  reply(response, 200, {
    cloudName: CLOUD_NAME,
    apiKey: credentials.apiKey,
    resourceType: policy.resourceType,
    parameters,
    signature: signParameters(parameters, credentials.apiSecret),
  });
}

async function complete(request, response) {
  const actor = await authenticated(request);
  const body = await readJson(request);
  const { purpose, publicId, version, signature } = body;
  if (typeof purpose !== 'string') throw Object.assign(new Error('Invalid media purpose.'), { status: 400 });
  let policy;
  try { policy = mediaPolicy(purpose, actor.decoded.uid, presets); }
  catch { throw Object.assign(new Error('Invalid media purpose.'), { status: 400 }); }
  authorize(purpose, actor);
  if (!validPublicId(publicId, policy.folder) ||
      !validResponseSignature({ publicId, version, signature, apiSecret: credentials.apiSecret })) {
    throw Object.assign(new Error('The upload proof is invalid.'), { status: 400 });
  }
  const asset = await fetchAsset(policy, publicId);
  if (!validAsset(asset, policy, publicId, version)) {
    throw Object.assign(new Error('Uploaded media does not match the requested type or size.'), { status: 400 });
  }
  if (purpose === 'avatar') {
    const profileReference = db.collection('users').doc(actor.decoded.uid);
    let previousPublicId;
    await db.runTransaction(async (transaction) => {
      const profile = await transaction.get(profileReference);
      if (profile.get('accountStatus') !== 'active') {
        throw Object.assign(new Error('This account cannot upload media.'), { status: 403 });
      }
      previousPublicId = profile.get('avatarPublicId');
      transaction.update(profileReference, {
        avatarUrl: asset.secure_url,
        avatarPublicId: publicId,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    if (previousPublicId !== publicId && validPublicId(previousPublicId, policy.folder)) {
      try { await deleteOldAvatar(previousPublicId); }
      catch (error) { console.warn('Old avatar cleanup failed:', error.message); }
    }
  }
  reply(response, 200, { secureUrl: asset.secure_url, publicId });
}

const server = createServer(async (request, response) => {
  if (request.method === 'GET' && request.url === '/health') {
    return reply(response, 200, { status: 'ok' });
  }
  if (request.method !== 'POST' || !['/media/sign', '/media/complete'].includes(request.url)) {
    return reply(response, 404, { error: 'Not found.' });
  }
  try {
    if (request.url === '/media/sign') await sign(request, response);
    else await complete(request, response);
  } catch (error) {
    if (!error.status) console.error('Media request failed:', error);
    reply(response, error.status ?? 500, { error: error.status ? error.message : 'Media service unavailable.' });
  }
});

const port = Number(process.env.PORT ?? 8080);
server.listen(port, '0.0.0.0', () => console.log(`Media backend listening on ${port}`));
