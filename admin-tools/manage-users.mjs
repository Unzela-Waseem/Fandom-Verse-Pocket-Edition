/**
 * Fandom Verse — Trusted Admin User Management Tool
 * ─────────────────────────────────────────────────
 * Runs with Firebase Admin SDK (server-side only).
 * Never include this script in the Flutter app bundle.
 *
 * Usage:
 *   node manage-users.mjs create-fan  --email=... --password=... [--name=...]
 *   node manage-users.mjs create-admin --email=... --password=... [--name=...]
 *   node manage-users.mjs delete-user  --uid=...
 *   node manage-users.mjs disable-user --uid=...
 *   node manage-users.mjs enable-user  --uid=...
 *   node manage-users.mjs list-users   [--limit=50]
 *
 * Prerequisites:
 *   1. Run: npm install   (inside admin-tools/)
 *   2. Set GOOGLE_APPLICATION_CREDENTIALS to a service-account key file, OR
 *      run from a machine authenticated with: gcloud auth application-default login
 */

import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

// ── Config ────────────────────────────────────────────────────────────────────

const PROJECT_ID = 'fandom-verse-pocket-unzela';

initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
const auth = getAuth();
const db = getFirestore();

// ── Arg parsing ───────────────────────────────────────────────────────────────

const [, , command, ...rawArgs] = process.argv;

const args = Object.fromEntries(
  rawArgs
    .filter((a) => a.startsWith('--'))
    .map((a) => {
      const [key, ...rest] = a.slice(2).split('=');
      return [key, rest.join('=')];
    }),
);

// ── Commands ──────────────────────────────────────────────────────────────────

async function createFan() {
  const { email, password, name } = args;
  if (!email || !password || password.length < 8) {
    fatal('--email and --password (min 8 chars) are required.');
  }
  const displayName = name?.trim() || 'Fan';
  await guardEmailFree(email);

  const user = await auth.createUser({
    email: email.trim().toLowerCase(),
    password,
    displayName,
    emailVerified: false,
    disabled: false,
  });

  try {
    await db.collection('users').doc(user.uid).create({
      uid: user.uid,
      displayName,
      email: email.trim().toLowerCase(),
      bio: '',
      avatarUrl: null,
      selectedFandoms: [],
      badge: 'New Explorer',
      role: 'fan',
      accountStatus: 'active',
      priceDropNotifications: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`✅  Fan created. UID: ${user.uid}  Email: ${user.email}`);
  } catch (err) {
    await auth.deleteUser(user.uid).catch(() => {});
    fatal(`Firestore write failed; Auth user rolled back. ${err.message}`);
  }
}

async function createAdmin() {
  const { email, password, name } = args;
  if (!email || !password || password.length < 12) {
    fatal('--email and --password (min 12 chars) are required for admin.');
  }
  const displayName = name?.trim() || 'Fandom Verse Admin';
  await guardEmailFree(email);

  const user = await auth.createUser({
    email: email.trim().toLowerCase(),
    password,
    displayName,
    emailVerified: false,
    disabled: false,
  });

  try {
    await auth.setCustomUserClaims(user.uid, { admin: true });
    await db.collection('users').doc(user.uid).create({
      uid: user.uid,
      displayName,
      email: email.trim().toLowerCase(),
      bio: '',
      avatarUrl: null,
      selectedFandoms: [],
      badge: 'Admin',
      role: 'admin',
      accountStatus: 'active',
      priceDropNotifications: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`✅  Admin provisioned. UID: ${user.uid}  Email: ${user.email}`);
  } catch (err) {
    await auth.deleteUser(user.uid).catch(() => {});
    fatal(`Setup failed; Auth user rolled back. ${err.message}`);
  }
}

async function deleteUser() {
  const { uid } = args;
  if (!uid) fatal('--uid is required.');

  // Prevent accidental deletion of the active admin running this script.
  const profile = await db.collection('users').doc(uid).get();
  if (!profile.exists) {
    console.warn('⚠️  No Firestore profile found for this UID. Proceeding with Auth-only deletion.');
  } else if (profile.data()?.role === 'admin') {
    fatal('Refusing to delete an admin account via this tool. Demote first.');
  }

  const answer = await prompt(
    `Delete Auth + Firestore record for UID ${uid}? Type DELETE to confirm: `,
  );
  if (answer !== 'DELETE') {
    console.log('Aborted.');
    process.exit(0);
  }

  // Write an audit record before deletion so there is a paper trail.
  await db.collection('audit_logs').add({
    actorId: 'cli-admin-tool',
    actorEmail: 'admin-tools/manage-users.mjs',
    action: 'delete-user',
    collection: 'users',
    recordId: uid,
    createdAt: FieldValue.serverTimestamp(),
  });

  const batch = db.batch();
  batch.delete(db.collection('users').doc(uid));
  await batch.commit().catch(() => {});   // best-effort Firestore removal
  await auth.deleteUser(uid);             // authoritative Auth deletion
  console.log(`✅  User ${uid} deleted from Auth and Firestore.`);
}

async function disableUser() {
  const { uid } = args;
  if (!uid) fatal('--uid is required.');
  await auth.updateUser(uid, { disabled: true });
  await db.collection('users').doc(uid).update({
    accountStatus: 'disabled',
    updatedAt: FieldValue.serverTimestamp(),
  });
  await db.collection('audit_logs').add({
    actorId: 'cli-admin-tool',
    actorEmail: 'admin-tools/manage-users.mjs',
    action: 'disable',
    collection: 'users',
    recordId: uid,
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log(`✅  User ${uid} disabled in both Auth and Firestore.`);
}

async function enableUser() {
  const { uid } = args;
  if (!uid) fatal('--uid is required.');
  await auth.updateUser(uid, { disabled: false });
  await db.collection('users').doc(uid).update({
    accountStatus: 'active',
    updatedAt: FieldValue.serverTimestamp(),
  });
  await db.collection('audit_logs').add({
    actorId: 'cli-admin-tool',
    actorEmail: 'admin-tools/manage-users.mjs',
    action: 'enable',
    collection: 'users',
    recordId: uid,
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log(`✅  User ${uid} enabled in both Auth and Firestore.`);
}

async function listUsers() {
  const limit = parseInt(args.limit ?? '50', 10);
  const result = await auth.listUsers(limit);
  console.log(`\nFound ${result.users.length} user(s):\n`);
  for (const user of result.users) {
    const profile = await db.collection('users').doc(user.uid).get();
    const role = profile.data()?.role ?? '?';
    const status = profile.data()?.accountStatus ?? '?';
    const disabled = user.disabled ? ' [AUTH DISABLED]' : '';
    console.log(
      `  ${user.uid}  ${user.email?.padEnd(40)}  role=${role}  status=${status}${disabled}`,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

async function guardEmailFree(email) {
  const existing = await auth
    .getUserByEmail(email.trim().toLowerCase())
    .catch((e) => {
      if (e.code === 'auth/user-not-found') return null;
      throw e;
    });
  if (existing) fatal(`Email ${email} is already registered. UID: ${existing.uid}`);
}

function fatal(msg) {
  console.error(`\n❌  ${msg}\n`);
  process.exit(1);
}

function prompt(question) {
  return new Promise((resolve) => {
    process.stdout.write(question);
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data.trim()));
    process.stdin.resume();
  });
}

// ── Router ────────────────────────────────────────────────────────────────────

const commands = {
  'create-fan': createFan,
  'create-admin': createAdmin,
  'delete-user': deleteUser,
  'disable-user': disableUser,
  'enable-user': enableUser,
  'list-users': listUsers,
};

if (!command || !commands[command]) {
  console.error(`
Usage: node manage-users.mjs <command> [options]

Commands:
  create-fan    --email=... --password=... [--name=...]
  create-admin  --email=... --password=... [--name=...]
  delete-user   --uid=...
  disable-user  --uid=...
  enable-user   --uid=...
  list-users    [--limit=50]
`);
  process.exit(1);
}

try {
  await commands[command]();
} catch (err) {
  console.error(`\n❌  ${err.message}\n`);
  process.exitCode = 1;
}
