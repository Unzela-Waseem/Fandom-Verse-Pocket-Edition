import 'package:fandom_verse_pocket/features/ai_helper/data/ai_fan_helper_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not require Firebase merely to construct the helper', () {
    expect(AiFanHelperService(), isA<AiFanHelperService>());
  });

  test('rejects an empty prompt before a network call', () async {
    await expectLater(
      AiFanHelperService().ask('   '),
      throwsA(isA<FormatException>()),
    );
  });
}
