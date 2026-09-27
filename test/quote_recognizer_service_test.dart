import 'package:fandom_verse_pocket/core/services/quote_recognizer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recognizes normalized speech-to-text variants locally', () {
    expect(
      QuoteRecognizerService.recognize("I'm Iron Man!")?.character,
      'Iron Man',
    );
    expect(
      QuoteRecognizerService.recognize('NO, I AM YOUR FATHER.')?.character,
      'Darth Vader',
    );
  });

  test('does not invent a match for unsupported dialogue', () {
    expect(
      QuoteRecognizerService.recognize('A completely unknown line'),
      isNull,
    );
  });

  test('exposes a non-empty local supported quote list', () {
    expect(QuoteRecognizerService.supportedQuotes, isNotEmpty);
  });
}
