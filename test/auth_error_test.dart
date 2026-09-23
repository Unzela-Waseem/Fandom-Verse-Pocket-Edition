import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse_pocket/features/authentication/data/auth_service.dart';

void main() {
  test('disabled sign-in provider receives an actionable error', () {
    final message = friendlyAuthError(
      FirebaseAuthException(code: 'operation-not-allowed'),
    );
    expect(message, contains('not been enabled'));
  });

  test('missing federated profile does not claim sign-in succeeded', () {
    const error = FederatedSignInException(
      'This account has no profile. Contact project support.',
    );
    expect(friendlyAuthError(error), contains('no profile'));
  });
}
