import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const KEY = JSON.parse(
  await import('fs').then(m => m.promises.readFile(
    '/home/muhammadfasih/Downloads/Chrome-Downloads/Fandomverse/admin-tools/key.json',
    'utf8'
  ))
);

initializeApp({ credential: cert(KEY) });
const db  = getFirestore();
const auth = getAuth();
const API_KEY = 'AIzaSyCgVeHnMw-rU68HBBAu3NPOwKgSkA0CQf4';

// Just fetch auth users to see if any exist
const users = await auth.listUsers(10);
console.log("Users in Auth:");
users.users.forEach(u => console.log(u.email, u.uid));

const docs = await db.collection('users').limit(10).get();
console.log("\nUsers in Firestore:");
docs.forEach(d => console.log(d.data().email, d.id, d.data().role));
