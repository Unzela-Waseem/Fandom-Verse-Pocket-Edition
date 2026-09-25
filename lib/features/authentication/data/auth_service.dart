import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FederatedSignInException implements Exception {
  const FederatedSignInException(this.message);

  final String message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  Future<void>? _googleInitialization;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle({
    String? displayName,
    List<String> fandoms = const [],
    String badge = 'New Explorer',
  }) async {
    if (kIsWeb) {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      await _ensureFanProfile(
        credential,
        displayName: displayName,
        fandoms: fandoms,
        badge: badge,
      );
      return;
    }
    _googleInitialization ??= GoogleSignIn.instance.initialize();
    await _googleInitialization;
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const FederatedSignInException(
        'Google sign-in is unavailable on this platform.',
      );
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const FederatedSignInException(
        'Google did not provide a sign-in token. Check the app configuration.',
      );
    }
    final credential = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    await _ensureFanProfile(
      credential,
      displayName: displayName,
      fandoms: fandoms,
      badge: badge,
    );
  }

  Future<void> signInWithApple({
    String? displayName,
    List<String> fandoms = const [],
    String badge = 'New Explorer',
  }) async {
    UserCredential credential;
    if (kIsWeb) {
      final provider = AppleAuthProvider();
      credential = await _auth.signInWithPopup(provider);
    } else {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      credential = await _auth.signInWithCredential(oauthCredential);
      displayName ??= [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');
      if (displayName.trim().isEmpty) displayName = null;
    }
    
    await _ensureFanProfile(
      credential,
      displayName: displayName,
      fandoms: fandoms,
      badge: badge,
    );
  }

  Future<void> _ensureFanProfile(
    UserCredential credential, {
    String? displayName,
    required List<String> fandoms,
    required String badge,
  }) async {
    final user = credential.user;
    if (user == null) {
      throw const FederatedSignInException('No account was returned.');
    }
    try {
      final profile = _firestore.collection('users').doc(user.uid);
      if ((await profile.get()).exists) return;
      if (credential.additionalUserInfo?.isNewUser != true) {
        throw const FederatedSignInException(
          'This account has no profile. Contact project support.',
        );
      }
      await profile.set({
        'uid': user.uid,
        'displayName': displayName?.trim().isNotEmpty == true
            ? displayName!.trim()
            : user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'New Explorer',
        'email': (user.email ?? '').trim().toLowerCase(),
        'bio': '',
        'avatarUrl': user.photoURL,
        'selectedFandoms': fandoms,
        'badge': badge,
        'role': 'fan',
        'accountStatus': 'active',
        'priceDropNotifications': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (credential.additionalUserInfo?.isNewUser == true) {
        await user.delete().catchError((_) {});
      }
      await _auth.signOut();
      rethrow;
    }
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
        await _auth.signOut().catchError((_) {});
      }
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}

String friendlyAuthError(Object error) {
  if (error is FederatedSignInException) return error.message;
  if (error is GoogleSignInException) {
    return error.code == GoogleSignInExceptionCode.canceled
        ? 'Google sign-in was canceled.'
        : 'Google sign-in failed. Check the provider configuration and try again.';
  }
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
      'operation-not-allowed' =>
        'This sign-in method has not been enabled for the project.',
      'unauthorized-domain' =>
        'This website is not authorized for sign-in. Add its domain in Firebase Authentication settings.',
      'popup-blocked' =>
        'Your browser blocked the sign-in popup. Allow popups and try again.',
      'popup-closed-by-user' => 'Sign-in was canceled.',
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
  return 'Something went wrong. Please try again.';
}
