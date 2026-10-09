import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';
import '../domain/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider =
    StreamProvider.autoDispose.family<AppUser, String>((
  ref,
  uid,
) async* {
  final profile = FirebaseFirestore.instance.collection('users').doc(uid);
  final authService = ref.read(authServiceProvider);
  var repairAttempted = false;
  var permissionRetries = 0;

  while (true) {
    try {
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
      return;
    } on FirebaseException catch (error) {
      // Immediately after admin -> fan (or fan -> admin) sign-out/sign-in,
      // Firestore can briefly evaluate the new listener with the prior token.
      // Refresh once or twice and reconnect rather than falsely blocking the
      // correctly signed-in account.
      if (error.code != 'permission-denied' || permissionRetries >= 2) {
        rethrow;
      }
      permissionRetries++;
      try {
        await authService.refreshSession(uid);
      } catch (_) {
        // If the currentUser is null or switched during hot restart / sign-out, break out gracefully
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }
});
