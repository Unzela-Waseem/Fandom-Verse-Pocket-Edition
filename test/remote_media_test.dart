import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse_pocket/core/media/remote_media.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';

void main() {
  test('only HTTPS media URLs without embedded credentials are accepted', () {
    expect(
      isHttpsMediaUrl(
        'https://res.cloudinary.com/example/image/upload/story.png',
      ),
      isTrue,
    );
    expect(isHttpsMediaUrl('http://example.com/video.mp4'), isFalse);
    expect(isHttpsMediaUrl('https://user:pass@example.com/file'), isFalse);
    expect(isHttpsMediaUrl('not-a-url'), isFalse);
  });

  test('saved content retains image and video metadata', () {
    const item = ContentItem(
      id: 'video-1',
      title: 'Video',
      summary: 'Summary',
      body: 'Body',
      category: 'Gaming',
      type: ContentType.video,
      creator: 'Editorial',
      tags: [],
      imageUrl: 'https://res.cloudinary.com/demo/image/upload/cover.jpg',
      videoUrl: 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
    );
    final restored = ContentItem.fromJson(item.toJson());
    expect(restored.imageUrl, item.imageUrl);
    expect(restored.videoUrl, item.videoUrl);
  });
}
