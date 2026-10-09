export function allowedWebOrigins(raw = '') {
  if (!raw.trim()) return new Set();
  const origins = raw.split(',').map((part) => part.trim());
  for (const origin of origins) {
    const parsed = URL.parse(origin);
    if (!parsed || parsed.origin !== origin || parsed.username || parsed.password ||
        (parsed.protocol !== 'https:' &&
          !(parsed.protocol === 'http:' && ['localhost', '127.0.0.1'].includes(parsed.hostname)))) {
      throw new Error('ALLOWED_WEB_ORIGINS must contain HTTPS origins or local development origins.');
    }
  }
  return new Set(origins);
}

export function isAllowedWebOrigin(origin, origins) {
  return typeof origin === 'string' && origins.has(origin);
}
