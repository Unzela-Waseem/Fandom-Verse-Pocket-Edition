import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../application/library_controller.dart';
import '../data/cloud_catalog.dart';
import '../data/demo_catalog.dart';
import '../domain/library_models.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialCategory = 'All'});

  final String initialCategory;

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

    return SafeArea(
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
            ...results.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                        height: 120,
                        width: double.infinity,
                        child: Image.asset(
                          AppAssets.multiverse,
                          fit: BoxFit.cover,
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
              ),
            ),
        ],
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
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(AppAssets.multiverse, fit: BoxFit.cover),
            ),
          ),
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
          Text(
            'By ${item.creator}',
            style: const TextStyle(color: Color(0xFFFFD740)),
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
              subtitle: Text('Saved locally on this device.'),
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
