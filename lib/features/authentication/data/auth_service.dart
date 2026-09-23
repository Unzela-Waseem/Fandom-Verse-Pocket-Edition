import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registerFan({
    required String displayName,
    required String email,
    required String password,
    required List<String> fandoms,
    required String badge,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(displayName.trim());
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': displayName.trim(),
        'email': email.trim().toLowerCase(),
        'bio': '',
        'avatarUrl': null,
        'selectedFandoms': fandoms,
        'badge': badge,
        'role': 'fan',
        'accountStatus': 'active',
        'priceDropNotifications': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (credential?.user != null) {
        await credential!.user!.delete().catchError((_) {});
      }
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}

String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already uses this email.',
      'weak-password' => 'Choose a stronger password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
  return 'Something went wrong. Please try again.';
}
