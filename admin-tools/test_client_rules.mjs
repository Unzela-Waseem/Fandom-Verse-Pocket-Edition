import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc, deleteDoc, writeBatch, serverTimestamp } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCgVeHnMw-rU68HBBAu3NPOwKgSkA0CQf4",
  projectId: "fandom-verse-pocket-unzela",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function run() {
  try {
    console.log("Signing in...");
    await signInWithEmailAndPassword(auth, "adminfandomverse@gmail.com", "AdminTest@12345!");
    console.log("Signed in as:", auth.currentUser.uid);

    const testUid = "test_fan_12345";

    console.log("Testing CREATE user...");
    await setDoc(doc(db, "users", testUid), {
      uid: testUid,
      displayName: "Test Fan Client",
      email: "client_test@fandomverse.test",
      bio: "",
      avatarUrl: null,
      selectedFandoms: [],
      badge: "New Explorer",
      role: "fan",
      accountStatus: "active",
      priceDropNotifications: false,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
      createdBy: auth.currentUser.uid,
    });
    console.log("✅ CREATE user SUCCESS");

    console.log("Testing DELETE user (with batch audit)...");
    const batch = writeBatch(db);
    batch.delete(doc(db, "users", testUid));
    
    const auditRef = doc(db, "audit_logs", "audit_test_123");
    batch.set(auditRef, {
      actorId: auth.currentUser.uid,
      actorEmail: auth.currentUser.email,
      action: "delete",
      collection: "users",
      recordId: testUid,
      createdAt: serverTimestamp()
    });
    
    await batch.commit();
    console.log("✅ DELETE user (with batch) SUCCESS");

  } catch (e) {
    console.error("❌ ERROR:", e.message);
  }
  process.exit();
}

run();
