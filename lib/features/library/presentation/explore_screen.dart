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

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedCategory;
  String _searchQuery = '';
  late TabController _tabController;

  static const _tabs = [
    (title: 'Videos', icon: Icons.video_library, type: ContentType.video),
    (title: 'Podcasts', icon: Icons.podcasts, type: ContentType.podcast),
    (title: 'Stories', icon: Icons.auto_stories, type: ContentType.story),
    (title: 'Galleries', icon: Icons.photo_library, type: ContentType.gallery),
    (title: 'News', icon: Icons.article, type: ContentType.news),
    (title: 'Profiles', icon: Icons.person_pin, type: ContentType.profile),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(contentCatalogProvider).asData?.value ?? contentCatalog;
    
    // Extract unique categories (Universes)
    final categories = ['All'];
    final uniqueCats = catalog.map((item) => item.category).toSet().toList()..sort();
    categories.addAll(uniqueCats);

    // If initialCategory is passed but not in list, fallback to All
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = 'All';
    }

    final query = _searchQuery.toLowerCase().trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.standalone
            ? (widget.initialCategory == 'All'
                ? 'Explore Fandoms'
                : 'Explore ${widget.initialCategory}')
            : 'Explore Fandoms'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFA855F7), // Theme accent
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(
            icon: Icon(t.icon, size: 20),
            text: t.title,
          )).toList(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.standalone) ...[
            // Universe Selection
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: const Text(
                'Select your Universe',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: const Color(0xFFA855F7),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                  );
                },
              ),
            ),
          ],

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search terms, profiles, or stories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      ),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tabInfo) {
                final items = catalog.where((item) {
                  final matchesType = item.type == tabInfo.type;
                  final matchesCat = _selectedCategory == 'All' || 
                                     item.category.toLowerCase() == _selectedCategory.toLowerCase();
                  final matchesSearch = query.isEmpty ||
                                        item.title.toLowerCase().contains(query) ||
                                        item.summary.toLowerCase().contains(query);
                  return matchesType && matchesCat && matchesSearch;
                }).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tabInfo.icon, size: 48, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'No ${tabInfo.title.toLowerCase()} found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search or universe filter.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF24232B),
                          backgroundImage: item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
                          child: item.imageUrl == null ? Icon(tabInfo.icon, color: const Color(0xFFA855F7)) : null,
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          item.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ContentDetailScreen(item: item),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
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
