import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';
const KEY = JSON.parse(await fs.promises.readFile('./key.json', 'utf8'));
initializeApp({ credential: cert(KEY) });
const db = getFirestore();

const doc = await db.collection('users').doc('7AZnewRUBvPH7eawGYllYtSemg52').get();
console.log("Admin accountStatus:", doc.data()?.accountStatus);
console.log("Admin role:", doc.data()?.role);
