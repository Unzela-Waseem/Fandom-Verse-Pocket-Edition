import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/remote_media.dart';
import '../application/library_controller.dart';
import '../data/cloud_catalog.dart';
import '../data/demo_catalog.dart';
import '../domain/library_models.dart';
import 'beginner_hub_screen.dart';
import 'deep_dive_screen.dart';

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
  String _resourceType = 'All';
  String _selectedCreator = 'All';
  String? _selectedTag;

  static const _trendingTags = [
    'anime',
    'marvel',
    'gaming',
    'scifi',
    'comics',
    'esports',
    'lore',
    'cosplay',
    'naruto',
    'news',
    'podcast',
    'trivia',
  ];

  static const _resourceTypeChoices = [
    'All',
    'News',
    'Galleries',
    'Videos',
    'Podcasts',
    'Stories',
    'Glossary',
    'Deep Dive',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  ContentType? _mapResourceNameToType(String name) {
    return switch (name) {
      'News' => ContentType.news,
      'Galleries' => ContentType.gallery,
      'Videos' => ContentType.video,
      'Podcasts' => ContentType.podcast,
      'Stories' => ContentType.story,
      'Glossary' => ContentType.glossary,
      'Deep Dive' => ContentType.deepDive,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cloudCatalog = ref.watch(contentCatalogProvider);
    final catalog = cloudCatalog.asData?.value ?? contentCatalog;
    final categories = [
      'All',
      ...{for (final item in catalog) item.category},
    ];

    final creators = [
      'All',
      ...{for (final item in catalog) item.creator},
    ];

    final results = catalog
        .where((item) {
          final query = _query.toLowerCase().trim();
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.summary.toLowerCase().contains(query) ||
              item.body.toLowerCase().contains(query) ||
              item.creator.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query));

          final matchesCategory =
              _category == 'All' || item.category == _category;

          final expectedType = _mapResourceNameToType(_resourceType);
          final matchesType = expectedType == null || item.type == expectedType;

          final matchesCreator =
              _selectedCreator == 'All' || item.creator == _selectedCreator;

          final matchesTag =
              _selectedTag == null ||
              item.tags.any(
                (tag) => tag.toLowerCase() == _selectedTag!.toLowerCase(),
              );

          return matchesQuery &&
              matchesCategory &&
              matchesType &&
              matchesCreator &&
              matchesTag;
        })
        .toList(growable: false);

    final library = ref.watch(libraryProvider);

    return Scaffold(
      appBar: widget.standalone ? AppBar(title: Text(_category)) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            if (!widget.standalone) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Multimedia hub, stories, news, and fandom universes.',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quick Hub Access Cards
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const BeginnerHubScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22362C), Color(0xFF14241B)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: const [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.black,
                              child: Icon(Icons.eco, size: 18),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Beginner Hub',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Glossary & terms',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white60,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DeepDiveScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF382342), Color(0xFF23132B)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD740).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: const [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFFFD740),
                              foregroundColor: Colors.black,
                              child: Icon(Icons.psychology, size: 18),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deep Dive',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Lore & trivia',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white60,
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
              const SizedBox(height: 14),
            ],

            if (cloudCatalog.hasError)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Cloud content is unavailable. Showing bundled items.',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),

            // Search Bar
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search by keyword (e.g. Marvel, Naruto, Anime)',
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

            if (!widget.standalone) ...[
              // Fandom Category Chips
              SizedBox(
                height: 38,
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
              const SizedBox(height: 12),
            ],

            // Resource / Media Type Chips
            const Row(
              children: [
                Icon(
                  Icons.perm_media_outlined,
                  size: 16,
                  color: Colors.white54,
                ),
                SizedBox(width: 4),
                Text(
                  'RESOURCES & MEDIA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _resourceTypeChoices.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final type = _resourceTypeChoices[index];
                  final isSelected = type == _resourceType;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _resourceType = type),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            if (!widget.standalone) ...[
              // Trending Tags Chips
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.deepOrangeAccent,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'TRENDING TAGS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: Colors.white60,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedTag != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedTag = null),
                      child: const Text(
                        'Clear tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFFD740),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingTags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, index) {
                    final tag = _trendingTags[index];
                    final isSelected = _selectedTag == tag;
                    return FilterChip(
                      label: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = selected ? tag : null;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Creator Filter Dropdown
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Creator:',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCreator,
                      isDense: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: creators
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c == 'All' ? 'All Creators' : c,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCreator = value ?? 'All'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Results count & reset filters if filtered
            Row(
              children: [
                Text(
                  '${results.length} ${results.length == 1 ? 'item' : 'items'} found',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                if (_query.isNotEmpty ||
                    _category != 'All' ||
                    _resourceType != 'All' ||
                    _selectedCreator != 'All' ||
                    _selectedTag != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _category = 'All';
                        _resourceType = 'All';
                        _selectedCreator = 'All';
                        _selectedTag = null;
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text(
                      'Reset filters',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (results.isEmpty)
              _EmptyResults(
                onReset: () {
                  setState(() {
                    _query = '';
                    _category = 'All';
                    _resourceType = 'All';
                    _selectedCreator = 'All';
                    _selectedTag = null;
                  });
                },
              )
            else
              ...results.map(
                (item) => Card(
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
                        Stack(
                          children: [
                            SizedBox(
                              height: 130,
                              width: double.infinity,
                              child: RemoteMediaImage(url: item.imageUrl),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(190),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFFD740),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  _resourceBadgeText(item.type),
                                  style: const TextStyle(
                                    color: Color(0xFFFFD740),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            if (item.type == ContentType.video)
                              const Positioned.fill(
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 10, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFFFFD740),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '· By ${item.creator}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
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
                                        fontSize: 13,
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
                                  color:
                                      library.bookmarkedContent.contains(
                                        item.id,
                                      )
                                      ? const Color(0xFFFFD740)
                                      : null,
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
      ),
    );
  }

  static String _resourceBadgeText(ContentType type) {
    return switch (type) {
      ContentType.news => '📰 NEWS',
      ContentType.gallery => '🖼️ GALLERY',
      ContentType.video => '🎬 VIDEO',
      ContentType.podcast => '🎧 PODCAST',
      ContentType.story => '✍️ STORY',
      ContentType.glossary => '📚 GLOSSARY',
      ContentType.deepDive => '🧠 DEEP DIVE',
      ContentType.profile => '👤 PROFILE',
      ContentType.beginnerGuide => '🌱 BEGINNER GUIDE',
    };
  }
}

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.item});

  final ContentItem item;

  void _openFullScreenViewer(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(240),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: RemoteMediaImage(url: imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            icon: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
              color: saved ? const Color(0xFFFFD740) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Media Header / Hero Image
          GestureDetector(
            onTap: item.type == ContentType.gallery
                ? () => _openFullScreenViewer(
                    context,
                    item.imageUrl ?? '',
                    item.title,
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RemoteMediaImage(url: item.imageUrl),
                    if (item.type == ContentType.gallery)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.fullscreen,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap for Fullscreen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
            style: const TextStyle(
              color: Color(0xFFFFD740),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Content Type & Category Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD740),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.type.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.category,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // If Podcast: Render interactive audio player
          if (item.type == ContentType.podcast) ...[
            _InteractivePodcastPlayer(item: item),
            const SizedBox(height: 20),
          ],

          // Body text
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Colors.white70,
            ),
          ),

          // If Gallery: Render multi-image showcase
          if (item.type == ContentType.gallery) ...[
            const SizedBox(height: 24),
            const Text(
              'Gallery Showcase (Tap any image to zoom)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD740),
              ),
            ),
            const SizedBox(height: 12),
            _GalleryGrid(
              item: item,
              onImageTap: (url, caption) =>
                  _openFullScreenViewer(context, url, caption),
            ),
          ],

          // If Video: Render video player
          if (isHttpsMediaUrl(item.videoUrl)) ...[
            const SizedBox(height: 20),
            RemoteMediaVideo(url: item.videoUrl!),
          ] else if (item.type == ContentType.video) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.ondemand_video, color: Color(0xFFFFD740)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Video stream ready for playback. Connect to view full stream.',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            children: item.tags
                .map((tag) => Chip(label: Text('#$tag')))
                .toList(),
          ),

          if (saved) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2E24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withAlpha(90),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.offline_pin, color: Color(0xFF4CAF50), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Offline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Text and metadata saved to your device. Accessible without internet.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InteractivePodcastPlayer extends StatefulWidget {
  const _InteractivePodcastPlayer({required this.item});

  final ContentItem item;

  @override
  State<_InteractivePodcastPlayer> createState() =>
      _InteractivePodcastPlayerState();
}

class _InteractivePodcastPlayerState extends State<_InteractivePodcastPlayer> {
  bool _isPlaying = false;
  double _progress = 0.25;
  String _speed = '1.0x';

  @override
  Widget build(BuildContext context) {
    const totalMinutes = 28;
    final currentSeconds = (_progress * totalMinutes * 60).round();
    final curMin = currentSeconds ~/ 60;
    final curSec = currentSeconds % 60;
    final timeString =
        '${curMin.toString().padLeft(2, '0')}:${curSec.toString().padLeft(2, '0')} / $totalMinutes:00';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF221F2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD740).withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFD740),
                foregroundColor: Colors.black,
                child: IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlaying
                          ? 'Now Playing Podcast'
                          : 'Tap to Play Podcast',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFFD740),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                initialValue: _speed,
                tooltip: 'Playback Speed',
                onSelected: (val) => setState(() => _speed = val),
                itemBuilder: (_) => [
                  '0.75x',
                  '1.0x',
                  '1.25x',
                  '1.5x',
                  '2.0x',
                ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                child: Chip(
                  label: Text(_speed, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _progress,
            activeColor: const Color(0xFFFFD740),
            onChanged: (val) => setState(() => _progress = val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                Text(
                  _isPlaying ? 'Audio Streaming' : 'Paused',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isPlaying ? Colors.greenAccent : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.item, required this.onImageTap});

  final ContentItem item;
  final void Function(String url, String caption) onImageTap;

  @override
  Widget build(BuildContext context) {
    final images = [
      {'title': 'Primary Visual / Hero Poster', 'url': item.imageUrl ?? ''},
      {'title': 'Character Concept Art', 'url': ''},
      {'title': 'Environment Background Matte', 'url': ''},
      {'title': 'Action Scene Keyframe', 'url': ''},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final img = images[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onImageTap(img['url']!, img['title']!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RemoteMediaImage(url: img['url']),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(200)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    img['title']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Icon(Icons.search_off, size: 54, color: Colors.white38),
        const SizedBox(height: 12),
        const Text(
          'No content matches these filters.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          'Try clearing search keywords or choosing "All" categories.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        if (onReset != null) ...[
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onReset,
            child: const Text('Reset all filters'),
          ),
        ],
      ],
    ),
  );
}
