import 'package:fandom_verse_pocket/core/validation/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidators', () {
    test('accepts a valid email', () {
      expect(InputValidators.email('fan@example.com'), isNull);
    });

    test('rejects a malformed email', () {
      expect(InputValidators.email('not-an-email'), isNotNull);
    });

    test('requires a strong password', () {
      expect(InputValidators.password('short'), isNotNull);
      expect(InputValidators.password('longpassword'), isNotNull);
      expect(InputValidators.password('Fandom123'), isNull);
    });

    test('login accepts existing passwords without applying signup policy', () {
      expect(InputValidators.loginPassword(''), isNotNull);
      expect(InputValidators.loginPassword('oldpassword'), isNull);
    });
  });
}
