import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import test from 'node:test';
import {
  CLOUD_NAME, credentialsFromEnvironment, mediaPolicy, signParameters,
  validAsset, validPublicId, validResponseSignature,
} from './cloudinary.mjs';

const presets = { avatar: 'avatar_signed', image: 'image_signed', video: 'video_signed' };
const publicIdSuffix = '8954f84a-13e4-4b44-b151-74b904e9f054';

test('accepts only the account provided by the project owner', () => {
  assert.deepEqual(
    credentialsFromEnvironment('cloudinary://key:secret@dc1w5stzg'),
    { cloudName: CLOUD_NAME, apiKey: 'key', apiSecret: 'secret' },
  );
  assert.throws(() => credentialsFromEnvironment('cloudinary://key:secret@wrong-cloud'));
});

test('limits Fan avatars to an owner-specific folder', () => {
  const own = mediaPolicy('avatar', 'fan-1', presets);
  const other = mediaPolicy('avatar', 'fan-2', presets);
  assert.notEqual(own.folder, other.folder);
  assert.equal(own.maxBytes, 5 * 1024 * 1024);
  assert.equal(own.resourceType, 'image');
  assert.equal(validPublicId(`${own.folder}/${publicIdSuffix}`, own.folder), true);
  assert.equal(validPublicId(`${other.folder}/${publicIdSuffix}`, own.folder), false);
  assert.equal(validPublicId(`${own.folder}/../../other`, own.folder), false);
});

test('uses separate editorial folders and presets', () => {
  const video = mediaPolicy('contentVideo', 'admin-1', presets);
  assert.equal(video.folder, 'fandom-verse/content/videos');
  assert.equal(video.resourceType, 'video');
  assert.equal(video.preset, 'video_signed');
  assert.equal(video.maxBytes, 100 * 1024 * 1024);
  assert.throws(() => mediaPolicy('unknown', 'admin-1', presets));
  assert.throws(() => mediaPolicy('avatar', 'fan-1', { ...presets, avatar: '' }));
});

test('signs sorted Cloudinary parameters and verifies response proofs', () => {
  const signature = signParameters({ timestamp: 123, folder: 'x', public_id: 'y' }, 'secret');
  const expected = createHash('sha1').update('folder=x&public_id=y&timestamp=123secret').digest('hex');
  assert.equal(signature, expected);
  const responseSignature = createHash('sha1')
    .update('public_id=x/y&version=123secret').digest('hex');
  assert.equal(validResponseSignature({
    publicId: 'x/y', version: 123, signature: responseSignature, apiSecret: 'secret',
  }), true);
  assert.equal(validResponseSignature({
    publicId: 'x/other', version: 123, signature: responseSignature, apiSecret: 'secret',
  }), false);
});

test('rejects oversized, wrong-format, and wrong-account assets', () => {
  const policy = mediaPolicy('avatar', 'fan-1', presets);
  const publicId = `${policy.folder}/${publicIdSuffix}`;
  const asset = {
    public_id: publicId,
    resource_type: 'image',
    type: 'upload',
    version: 123,
    bytes: 1000,
    format: 'jpg',
    secure_url: `https://res.cloudinary.com/${CLOUD_NAME}/image/upload/v123/${publicId}.jpg`,
  };
  assert.equal(validAsset(asset, policy, publicId, 123), true);
  assert.equal(validAsset({ ...asset, bytes: 6000000 }, policy, publicId, 123), false);
  assert.equal(validAsset({ ...asset, format: 'svg' }, policy, publicId, 123), false);
  assert.equal(validAsset({ ...asset, secure_url: 'https://evil.example/file.jpg' }, policy, publicId, 123), false);
});
