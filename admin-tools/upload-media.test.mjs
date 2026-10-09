import assert from 'node:assert/strict';
import test from 'node:test';
import { matchesMediaSignature, mediaTypeFor, signUpload } from './upload-media.mjs';

test('recognizes only supported media extensions', () => {
  assert.deepEqual(mediaTypeFor('cover.PNG'), ['image', 'image/png', 5242880]);
  assert.deepEqual(mediaTypeFor('trailer.mp4'), ['video', 'video/mp4', 104857600]);
  assert.equal(mediaTypeFor('secret.exe'), null);
});

test('rejects a disguised non-image file', () => {
  assert.equal(matchesMediaSignature(Buffer.from('not an image'), 'image/png'), false);
  assert.equal(
    matchesMediaSignature(Buffer.from('89504e470d0a1a0a', 'hex'), 'image/png'),
    true,
  );
});

test('produces a deterministic signature without exposing a secret', () => {
  const result = signUpload({
    folder: 'fandom-verse',
    publicId: 'sample',
    timestamp: 123,
    apiSecret: 'private-test-value',
  });
  assert.match(result, /^[a-f0-9]{40}$/);
  assert.equal(result, signUpload({
    folder: 'fandom-verse',
    publicId: 'sample',
    timestamp: 123,
    apiSecret: 'private-test-value',
  }));
});
