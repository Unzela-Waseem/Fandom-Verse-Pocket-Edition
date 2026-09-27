import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';
import '../domain/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider = StreamProvider.family<AppUser, String>((
  ref,
  uid,
) async* {
  final profile = FirebaseFirestore.instance.collection('users').doc(uid);
  final authService = ref.read(authServiceProvider);
  var repairAttempted = false;

  await for (final snapshot in profile.snapshots()) {
    if (!snapshot.exists) {
      // Firebase Auth becomes available before the registration screen's
      // Firestore write completes. Do not interpret that normal race as a
      // denied account. The repair can only create the signed-in user's own
      // unprivileged fan profile under the Firestore rules.
      if (!repairAttempted) {
        repairAttempted = true;
        await authService.ensureFanProfile(uid);
      }
      continue;
    }
    yield AppUser.fromFirestore(snapshot);
  }
});
