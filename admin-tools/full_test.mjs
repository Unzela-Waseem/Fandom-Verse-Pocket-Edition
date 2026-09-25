/**
 * Full test script
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import fs from 'fs';

const KEY = JSON.parse(await fs.promises.readFile('./key.json', 'utf8'));

initializeApp({ credential: cert(KEY) });
const db  = getFirestore();
const auth = getAuth();
const API_KEY = 'AIzaSyCgVeHnMw-rU68HBBAu3NPOwKgSkA0CQf4';

const TEST_FAN_EMAIL   = `testfan_${Date.now()}@fandomverse.test`;
const TEST_PASSWORD_FAN   = 'FanTest@1234';

async function restSignUp(email, password, displayName) {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, displayName, returnSecureToken: true }),
    }
  );
  return res.json();
}

console.log('─── TEST 1: Add Fan User ───');
let fanUid;
try {
  const authRes = await restSignUp(TEST_FAN_EMAIL, TEST_PASSWORD_FAN, 'Test Fan');
  if (authRes.error) throw new Error(authRes.error.message);
  fanUid = authRes.localId;
  console.log(`✅ Auth REST API creates Fan account (UID: ${fanUid})`);

  // Write Firestore profile
  await db.collection('users').doc(fanUid).set({
    uid: fanUid,
    displayName: 'Test Fan',
    email: TEST_FAN_EMAIL,
    bio: '',
    avatarUrl: null,
    selectedFandoms: [],
    badge: 'New Explorer',
    role: 'fan',
    accountStatus: 'active',
    priceDropNotifications: false,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    createdBy: 'test-script',
  });
  console.log('✅ Firestore profile written for Fan');
} catch (e) {
  console.log('❌ Add Fan User failed:', e.message);
}

// ── TEST 2: Delete Fan user ──
console.log('\n─── TEST 2: Delete Fan User ───');
try {
  await db.collection('users').doc(fanUid).delete();
  console.log('✅ Firestore profile deleted');
  await auth.deleteUser(fanUid);
  console.log('✅ Firebase Auth account deleted');
} catch (e) {
  console.log('❌ Delete Fan User failed:', e.message);
}
