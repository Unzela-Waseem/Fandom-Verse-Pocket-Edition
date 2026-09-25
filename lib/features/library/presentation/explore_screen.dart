import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/remote_media.dart';
import '../application/library_controller.dart';
import '../data/cloud_catalog.dart';
import '../data/demo_catalog.dart';
import '../domain/library_models.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({
    super.key,
    this.initialCategory = 'All',
    this.standalone = false,
  });

  final String initialCategory;
  final bool standalone;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _query = '';
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final cloudCatalog = ref.watch(contentCatalogProvider);
    final catalog = cloudCatalog.asData?.value ?? contentCatalog;
    final categories = [
      'All',
      ...{for (final item in catalog) item.category},
    ];
    final results = catalog
        .where((item) {
          final query = _query.toLowerCase().trim();
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.summary.toLowerCase().contains(query) ||
              item.creator.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query));
          return matchesQuery &&
              (_category == 'All' || item.category == _category);
        })
        .toList(growable: false);
    final library = ref.watch(libraryProvider);

    return Scaffold(
      appBar: widget.standalone ? AppBar(title: Text(_category)) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const Text(
              'Explore',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Stories, profiles, news, media, glossary terms, and advanced lore.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            if (cloudCatalog.hasError)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Cloud content is unavailable. Showing bundled items.',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search by keyword, creator, or tag',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => _query = ''),
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return ChoiceChip(
                    label: Text(category),
                    selected: category == _category,
                    onSelected: (_) => setState(() => _category = category),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (results.isEmpty)
              const _EmptyResults()
            else
              ...results.map((item) {
                final hasVideo = isHttpsMediaUrl(item.videoUrl);
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ContentDetailScreen(item: item),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RemoteMediaImage(
                                url: item.imageUrl,
                                videoUrlForPoster: item.videoUrl,
                              ),
                              if (hasVideo || item.type == ContentType.video) ...[
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black45,
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withAlpha(220),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'VIDEO',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFFFD740),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip:
                                    library.bookmarkedContent.contains(item.id)
                                    ? 'Remove offline bookmark'
                                    : 'Save offline',
                                onPressed: () => ref
                                    .read(libraryProvider.notifier)
                                    .toggleBookmark(item.id, item: item),
                                icon: Icon(
                                  library.bookmarkedContent.contains(item.id)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref
        .watch(libraryProvider)
        .bookmarkedContent
        .contains(item.id);
    final hasVideo = isHttpsMediaUrl(item.videoUrl);
    final hasImage = isHttpsMediaUrl(item.imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.category),
        actions: [
          IconButton(
            tooltip: saved
                ? 'Remove offline bookmark'
                : 'Save for offline access',
            onPressed: () => ref
                .read(libraryProvider.notifier)
                .toggleBookmark(item.id, item: item),
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (hasVideo) ...[
            RemoteMediaVideo(
              url: item.videoUrl!,
              posterUrl: item.imageUrl,
            ),
            if (hasImage) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: RemoteMediaImage(url: item.imageUrl),
                ),
              ),
            ],
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RemoteMediaImage(url: item.imageUrl),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'By ${item.creator}',
                style: const TextStyle(
                  color: Color(0xFFFFD740),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasVideo) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VIDEO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            children: item.tags
                .map((tag) => Chip(label: Text('#$tag')))
                .toList(),
          ),
          if (saved) ...[
            const SizedBox(height: 16),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.offline_pin, color: Colors.greenAccent),
              title: Text('Available offline'),
              subtitle: Text(
                'Article text is saved on this device. Images and video require internet.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 64),
    child: Column(
      children: [
        Icon(Icons.search_off, size: 54, color: Colors.white38),
        SizedBox(height: 12),
        Text('No content matches these filters.'),
      ],
    ),
  );
}
