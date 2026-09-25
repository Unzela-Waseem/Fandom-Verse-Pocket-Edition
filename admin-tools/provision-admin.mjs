import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

const projectId = 'fandom-verse-pocket-unzela';
const email = process.env.FANDOM_ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.FANDOM_ADMIN_PASSWORD;
const displayName = process.env.FANDOM_ADMIN_NAME?.trim() || 'Fandom Verse Admin';

if (!email || !password || password.length < 12) {
  console.error(
    'Set FANDOM_ADMIN_EMAIL and a FANDOM_ADMIN_PASSWORD of at least 12 characters.',
  );
  process.exit(1);
}

initializeApp({ credential: applicationDefault(), projectId });
const auth = getAuth();
const firestore = getFirestore();

try {
  const existing = await auth.getUserByEmail(email).catch((error) => {
    if (error.code === 'auth/user-not-found') return null;
    throw error;
  });
  if (existing) {
    throw new Error(
      'An Authentication account already uses this email. Existing accounts are never promoted automatically.',
    );
  }

  const user = await auth.createUser({
    email,
    password,
    displayName,
    emailVerified: false,
    disabled: false,
  });
  try {
    await auth.setCustomUserClaims(user.uid, { admin: true });
    await firestore.collection('users').doc(user.uid).create({
      uid: user.uid,
      displayName,
      email,
      bio: '',
      avatarUrl: null,
      selectedFandoms: [],
      badge: 'Admin',
      role: 'admin',
      accountStatus: 'active',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    await auth.deleteUser(user.uid).catch((rollbackError) => {
      console.error('Rollback failed; remove the incomplete Auth user manually.', rollbackError);
    });
    throw error;
  }
  console.log(`Admin provisioned in ${projectId}. UID: ${user.uid}`);
} catch (error) {
  console.error('Admin provisioning failed:', error.message);
  process.exitCode = 1;
}
