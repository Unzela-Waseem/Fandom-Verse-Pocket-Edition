import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import fs from 'fs';
const KEY = JSON.parse(await fs.promises.readFile('./key.json', 'utf8'));
initializeApp({ credential: cert(KEY) });
const db = getFirestore();

console.log("--- RECENT USERS ---");
const users = await db.collection('users').orderBy('createdAt', 'desc').limit(5).get();
users.forEach(u => console.log(u.id, u.data().email, u.data().createdAt));

console.log("\n--- RECENT AUDIT LOGS ---");
const audits = await db.collection('audit_logs').orderBy('createdAt', 'desc').limit(5).get();
audits.forEach(a => console.log(a.id, a.data().action, a.data().recordId, a.data().actorEmail));
