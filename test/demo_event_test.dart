import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse_pocket/features/library/data/demo_catalog.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';

void main() {
  test('bundled sample events never expose live venue or ticket actions', () {
    expect(eventCatalog, isNotEmpty);
    expect(eventCatalog.every((event) => event.isDemo), isTrue);
    expect(eventCatalog.every((event) => event.ticketUrl.isEmpty), isTrue);
  });

  test('sample event flag survives offline agenda serialization', () {
    final sample = eventCatalog.first;
    final restored = FandomEvent.fromJson(sample.toJson());
    expect(restored.isDemo, isTrue);
    expect(restored.ticketUrl, isEmpty);
  });

  test('older saved previews cannot reopen placeholder ticket links', () {
    final oldJson = eventCatalog.first.toJson()
      ..remove('isDemo')
      ..['ticketUrl'] = 'https://example.com/events/karachi-cosplay';
    final restored = FandomEvent.fromJson(oldJson);
    expect(restored.isDemo, isTrue);
    expect(restored.ticketUrl, isEmpty);
  });
}
