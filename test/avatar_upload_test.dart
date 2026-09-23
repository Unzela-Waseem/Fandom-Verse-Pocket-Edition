import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse_pocket/features/profile/data/avatar_upload_service.dart';

void main() {
  test('avatar MIME type is determined from file bytes', () {
    expect(
      supportedAvatarMime(Uint8List.fromList([0xff, 0xd8, 0xff, 0x00])),
      'image/jpeg',
    );
    expect(
      supportedAvatarMime(
        Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
      ),
      'image/png',
    );
    expect(
      supportedAvatarMime(Uint8List.fromList('RIFFxxxxWEBP'.codeUnits)),
      'image/webp',
    );
  });

  test('non-images and unsupported formats are rejected', () {
    expect(supportedAvatarMime(Uint8List.fromList('hello'.codeUnits)), isNull);
    expect(supportedAvatarMime(Uint8List(0)), isNull);
  });
}
