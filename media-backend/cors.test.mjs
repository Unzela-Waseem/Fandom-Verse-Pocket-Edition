import assert from 'node:assert/strict';
import test from 'node:test';
import { allowedWebOrigins, isAllowedWebOrigin } from './cors.mjs';

test('accepts exact HTTPS and local development origins', () => {
  const origins = allowedWebOrigins('http://localhost:7357, https://app.example');
  assert.equal(isAllowedWebOrigin('http://localhost:7357', origins), true);
  assert.equal(isAllowedWebOrigin('https://app.example', origins), true);
  assert.equal(isAllowedWebOrigin('https://evil.example', origins), false);
  assert.equal(isAllowedWebOrigin('http://localhost:9999', origins), false);
});

test('rejects broad or malformed web origins', () => {
  assert.throws(() => allowedWebOrigins('*'));
  assert.throws(() => allowedWebOrigins('http://app.example'));
  assert.throws(() => allowedWebOrigins('https://app.example/path'));
  assert.throws(() => allowedWebOrigins('https://user@app.example'));
});
