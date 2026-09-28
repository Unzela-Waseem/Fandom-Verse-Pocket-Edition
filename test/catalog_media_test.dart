import 'package:fandom_verse_pocket/core/media/remote_media.dart';
import 'package:fandom_verse_pocket/features/library/data/demo_catalog.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled Explore catalog has unique cards and local video media', () {
    expect(contentCatalog.map((item) => item.id).toSet().length,
        contentCatalog.length);
    expect(contentCatalog.map((item) => item.title).toSet().length,
        contentCatalog.length);

    final videos = contentCatalog
        .where((item) => item.type == ContentType.video)
        .toList(growable: false);
    expect(videos, hasLength(2));
    expect(videos.map((item) => item.videoUrl).toSet().length, videos.length);
    expect(videos.every((item) => isAssetMediaUrl(item.videoUrl)), isTrue);
    expect(videos.every((item) => isPlayableMediaUrl(item.videoUrl)), isTrue);
  });
}
