import { createHash, randomUUID } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import { basename, extname } from 'node:path';

const types = new Map([
  ['.jpg', ['image', 'image/jpeg', 5 * 1024 * 1024]],
  ['.jpeg', ['image', 'image/jpeg', 5 * 1024 * 1024]],
  ['.png', ['image', 'image/png', 5 * 1024 * 1024]],
  ['.webp', ['image', 'image/webp', 5 * 1024 * 1024]],
  ['.mp4', ['video', 'video/mp4', 100 * 1024 * 1024]],
  ['.mov', ['video', 'video/quicktime', 100 * 1024 * 1024]],
  ['.webm', ['video', 'video/webm', 100 * 1024 * 1024]],
]);

function cloudinaryCredentials() {
  const raw = process.env.CLOUDINARY_URL;
  if (!raw) throw new Error('Set CLOUDINARY_URL in a private .env file.');
  const parsed = new URL(raw);
  if (parsed.protocol !== 'cloudinary:' || !parsed.hostname ||
      !parsed.username || !parsed.password) {
    throw new Error('CLOUDINARY_URL is not a valid Cloudinary environment URL.');
  }
  return {
    cloudName: parsed.hostname,
    apiKey: decodeURIComponent(parsed.username),
    apiSecret: decodeURIComponent(parsed.password),
  };
}

export function mediaTypeFor(path) {
  return types.get(extname(path).toLowerCase()) ?? null;
}

export function matchesMediaSignature(bytes, mimeType) {
  if (mimeType === 'image/jpeg') {
    return bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  }
  if (mimeType === 'image/png') {
    return bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex'));
  }
  if (mimeType === 'image/webp') {
    return bytes.length >= 12 && bytes.toString('ascii', 0, 4) === 'RIFF' &&
      bytes.toString('ascii', 8, 12) === 'WEBP';
  }
  if (mimeType === 'video/mp4' || mimeType === 'video/quicktime') {
    return bytes.length >= 12 && bytes.toString('ascii', 4, 8) === 'ftyp';
  }
  if (mimeType === 'video/webm') {
    return bytes.length >= 4 && bytes.subarray(0, 4).equals(Buffer.from('1a45dfa3', 'hex'));
  }
  return false;
}

export function signUpload({ folder, publicId, timestamp, apiSecret }) {
  return createHash('sha1')
    .update(`folder=${folder}&public_id=${publicId}&timestamp=${timestamp}${apiSecret}`)
    .digest('hex');
}

async function main() {
  const filePath = process.argv[2];
  if (!filePath) {
    throw new Error('Usage: node --env-file=.env admin-tools/upload-media.mjs <file>');
  }
  const selected = mediaTypeFor(filePath);
  if (!selected) {
    throw new Error('Only JPEG, PNG, WebP, MP4, MOV, and WebM are supported.');
  }
  const [resourceType, mimeType, maxBytes] = selected;
  const fileInfo = await stat(filePath);
  if (!fileInfo.isFile() || fileInfo.size === 0 || fileInfo.size > maxBytes) {
    throw new Error(`File must be non-empty and no larger than ${maxBytes / 1024 / 1024} MB.`);
  }
  const credentials = cloudinaryCredentials();
  const fileBytes = await readFile(filePath);
  if (!matchesMediaSignature(fileBytes, mimeType)) {
    throw new Error('The file content does not match its media extension.');
  }
  const folder = 'fandom-verse';
  const publicId = randomUUID();
  const timestamp = Math.floor(Date.now() / 1000);
  const signature = signUpload({
    folder,
    publicId,
    timestamp,
    apiSecret: credentials.apiSecret,
  });
  const form = new FormData();
  form.set('file', new Blob([fileBytes], { type: mimeType }), basename(filePath));
  form.set('api_key', credentials.apiKey);
  form.set('timestamp', String(timestamp));
  form.set('folder', folder);
  form.set('public_id', publicId);
  form.set('signature', signature);
  const endpoint = `https://api.cloudinary.com/v1_1/${credentials.cloudName}/${resourceType}/upload`;
  const response = await fetch(endpoint, { method: 'POST', body: form });
  const result = await response.json();
  if (!response.ok || typeof result.secure_url !== 'string') {
    throw new Error(result.error?.message ?? `Upload failed (${response.status}).`);
  }
  console.log(JSON.stringify({
    secureUrl: result.secure_url,
    publicId: result.public_id,
    resourceType: result.resource_type,
    bytes: result.bytes,
  }, null, 2));
}

if (process.argv[1]?.endsWith('/upload-media.mjs')) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
