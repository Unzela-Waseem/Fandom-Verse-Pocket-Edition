import { createHash, timingSafeEqual } from 'node:crypto';

export const CLOUD_NAME = 'dc1w5stzg';
export const MAX_BYTES = Object.freeze({
  avatar: 5 * 1024 * 1024,
  contentImage: 10 * 1024 * 1024,
  contentVideo: 100 * 1024 * 1024,
  eventImage: 10 * 1024 * 1024,
  productImage: 10 * 1024 * 1024,
});

const imageFormats = new Set(['jpg', 'png', 'webp']);
const videoFormats = new Set(['mp4', 'mov', 'webm']);

export function credentialsFromEnvironment(raw = process.env.CLOUDINARY_URL) {
  if (!raw) throw new Error('CLOUDINARY_URL is required.');
  const parsed = new URL(raw);
  if (parsed.protocol !== 'cloudinary:' || parsed.hostname !== CLOUD_NAME ||
      !parsed.username || !parsed.password) {
    throw new Error(`CLOUDINARY_URL must use the ${CLOUD_NAME} cloud and include an API key and secret.`);
  }
  return {
    cloudName: CLOUD_NAME,
    apiKey: decodeURIComponent(parsed.username),
    apiSecret: decodeURIComponent(parsed.password),
  };
}

export function mediaPolicy(purpose, uid, presets) {
  if (!Object.hasOwn(MAX_BYTES, purpose)) throw new Error('Unsupported media purpose.');
  const owner = createHash('sha256').update(uid).digest('hex').slice(0, 32);
  const folders = {
    avatar: `fandom-verse/avatars/${owner}`,
    contentImage: 'fandom-verse/content/images',
    contentVideo: 'fandom-verse/content/videos',
    eventImage: 'fandom-verse/events/images',
    productImage: 'fandom-verse/merchandise/images',
  };
  const video = purpose === 'contentVideo';
  const preset = purpose === 'avatar' ? presets.avatar : video ? presets.video : presets.image;
  if (!preset || !/^[a-zA-Z0-9_-]{1,100}$/.test(preset)) {
    throw new Error(`A signed Cloudinary preset is missing for ${purpose}.`);
  }
  return {
    folder: folders[purpose],
    resourceType: video ? 'video' : 'image',
    allowedFormats: video ? 'mp4,mov,webm' : 'jpg,png,webp',
    formats: video ? videoFormats : imageFormats,
    maxBytes: MAX_BYTES[purpose],
    preset,
  };
}

export function signParameters(parameters, apiSecret) {
  const serialized = Object.entries(parameters)
    .filter(([key, value]) => !['file', 'api_key', 'cloud_name', 'resource_type', 'signature'].includes(key) && value != null)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join('&');
  return createHash('sha1').update(`${serialized}${apiSecret}`).digest('hex');
}

export function validResponseSignature({ publicId, version, signature, apiSecret }) {
  if (typeof publicId !== 'string' || typeof version !== 'number' ||
      !Number.isSafeInteger(version) || version <= 0 ||
      typeof signature !== 'string' || !/^[a-f0-9]{40}$/i.test(signature)) return false;
  const expected = createHash('sha1')
    .update(`public_id=${publicId}&version=${version}${apiSecret}`)
    .digest();
  return timingSafeEqual(expected, Buffer.from(signature, 'hex'));
}

export function validPublicId(publicId, folder) {
  return typeof publicId === 'string' &&
    new RegExp(`^${folder}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`, 'i').test(publicId);
}

export function validAsset(asset, policy, publicId, version) {
  if (!asset || asset.public_id !== publicId || asset.resource_type !== policy.resourceType ||
      asset.type !== 'upload' || asset.version !== version ||
      !Number.isSafeInteger(asset.bytes) || asset.bytes <= 0 ||
      asset.bytes > policy.maxBytes || !policy.formats.has(asset.format)) return false;
  const delivery = URL.parse(asset.secure_url);
  return delivery?.protocol === 'https:' && delivery.hostname === 'res.cloudinary.com' &&
    delivery.pathname.startsWith(`/${CLOUD_NAME}/${policy.resourceType}/upload/v${version}/`) &&
    !delivery.username && !delivery.password && !delivery.search && !delivery.hash;
}
