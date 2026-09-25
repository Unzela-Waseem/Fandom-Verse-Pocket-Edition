import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/media/remote_media.dart';
import '../../authentication/domain/app_user.dart';
import '../../events/presentation/events_screen.dart';
import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';
import '../../library/presentation/beginner_hub_screen.dart';
import '../../library/presentation/deep_dive_screen.dart';
import '../../library/presentation/explore_screen.dart';
import '../../merchandise/presentation/store_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../notifications/data/notification_device_service.dart';
import '../../profile/presentation/profile_screen.dart';

class FanShell extends StatefulWidget {
  const FanShell({super.key, this.profile});

  final AppUser? profile;

  @override
  State<FanShell> createState() => _FanShellState();
}

class _FanShellState extends State<FanShell> {
  int _index = 0;
  StreamSubscription<String>? _tokenSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null && !kIsWeb && Firebase.apps.isNotEmpty) {
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((
        token,
      ) {
        final profile = widget.profile;
        if (profile?.priceDropNotifications != true ||
            FirebaseAuth.instance.currentUser?.uid != profile?.uid) {
          return;
        }
        unawaited(
          NotificationDeviceService.saveToken(
            profile!.uid,
            token,
          ).catchError((Object _) {}),
        );
      });
      unawaited(_registerIfPermitted());
    }
  }

  @override
  void didUpdateWidget(covariant FanShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb &&
        oldWidget.profile?.priceDropNotifications != true &&
        widget.profile?.priceDropNotifications == true) {
      unawaited(_registerIfPermitted());
    }
  }

  Future<void> _registerIfPermitted() async {
    if (kIsWeb || Firebase.apps.isEmpty) return;
    final profile = widget.profile;
    if (profile?.priceDropNotifications != true) return;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (FirebaseAuth.instance.currentUser?.uid == profile?.uid) {
          await NotificationDeviceService.saveCurrentToken(profile!.uid);
        }
      }
    } catch (_) {
      // The in-app notification center still works without device push.
    }
  }

  @override
  void dispose() {
    unawaited(_tokenSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        profile: widget.profile,
        openExplore: () => setState(() => _index = 1),
      ),
      const ExploreScreen(),
      const EventsScreen(),
      const StoreScreen(),
      ProfileScreen(profile: widget.profile),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        return Scaffold(
          backgroundColor: const Color(0xFF09040E),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (value) =>
                          setState(() => _index = value),
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: const Color(0xFF0C0616),
                      indicatorColor: const Color(0xFFA855F7),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.explore_outlined),
                          selectedIcon: Icon(Icons.explore),
                          label: Text('Explore'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.calendar_month_outlined),
                          selectedIcon: Icon(Icons.calendar_month),
                          label: Text('Events'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.shopping_bag_outlined),
                          selectedIcon: Icon(Icons.shopping_bag),
                          label: Text('Store'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFF26123D)),
                    Expanded(
                      child: IndexedStack(index: _index, children: pages),
                    ),
                  ],
                )
              : IndexedStack(index: _index, children: pages),
          bottomNavigationBar: wide
              ? null
              : Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF26123D), width: 1),
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _index,
                    height: 68,
                    backgroundColor: const Color(0xFF0C0616),
                    indicatorColor: const Color(0xFFA855F7),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    onDestinationSelected: (value) =>
                        setState(() => _index = value),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore),
                        label: 'Explore',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.calendar_month_outlined),
                        selectedIcon: Icon(Icons.calendar_month),
                        label: 'Events',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.shopping_bag_outlined),
                        selectedIcon: Icon(Icons.shopping_bag),
                        label: 'Store',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.openExplore, this.profile});

  final AppUser? profile;
  final VoidCallback openExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog =
        ref.watch(contentCatalogProvider).asData?.value ?? contentCatalog;
    final featured = catalog.where((item) => item.trending).toList();
    if (featured.isEmpty) featured.addAll(catalog.take(4));
    final categories = catalog.map((item) => item.category).toSet().toList();

    // Personalized fandom items based on profile.selectedFandoms
    final userFandoms = profile?.selectedFandoms ?? const [];
    final personalized = userFandoms.isNotEmpty
        ? catalog
            .where(
              (item) => userFandoms.any(
                (f) => f.toLowerCase() == item.category.toLowerCase(),
              ),
            )
            .take(4)
            .toList()
        : <ContentItem>[];

    return SafeArea(
      child: Stack(
        children: [
          // Background ambient radial light glow effects inspired by reference UI
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 300,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [Color(0x55A855F7), Color(0x0009040E)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 550,
            right: -80,
            width: 260,
            height: 260,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Color(0x35D946EF), Color(0x0009040E)],
                  ),
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverList.list(
                  children: [
                    _TopBar(profile: profile, openExplore: openExplore),
                    const SizedBox(height: 18),
                    _HeroCard(openExplore: openExplore),
                    const SizedBox(height: 22),
                    const _StatsSection(),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Explore fandoms',
                      action: 'View all',
                      onPressed: openExplore,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, index) => _CategoryAvatar(
                          category: categories[index],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ExploreScreen(
                                initialCategory: categories[index],
                                standalone: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _TrendingFandomCarousel(),
                    const SizedBox(height: 24),
                    const _HubQuickCards(),
                    if (personalized.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle(
                        title: 'Curated for you',
                        action: 'See all',
                        onPressed: openExplore,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: personalized.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, index) => _CuratedMiniCard(
                            item: personalized[index],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Featured stories',
                      action: 'See more',
                      onPressed: openExplore,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.builder(
                  itemCount: featured.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .72,
                  ),
                  itemBuilder: (_, index) => _StoryCard(item: featured[index]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.openExplore, this.profile});

  final AppUser? profile;
  final VoidCallback openExplore;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF180A2E),
          child: Icon(Icons.person, color: Color(0xFFE9D5FF), size: 22),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(color: Color(0xFFC084FC), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              profile?.displayName ?? 'Fandom Explorer',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C0D38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
        ),
        child: IconButton(
          tooltip: 'Explore and search',
          onPressed: openExplore,
          icon: const Icon(Icons.search, color: Color(0xFFE9D5FF)),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C0D38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
        ),
        child: IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
          ),
          icon: const Icon(Icons.notifications_none, color: Color(0xFFE9D5FF)),
        ),
      ),
    ],
  );
}

/// Statistics metrics row matching the reference image section ("42 / 204 / 24M / 112")
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF140926),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatTile(number: '42M+', label: 'Total Reads'),
          _StatDivider(),
          _StatTile(number: '204+', label: 'Universes'),
          _StatDivider(),
          _StatTile(number: '24M+', label: 'Active Fans'),
          _StatDivider(),
          _StatTile(number: '112+', label: 'Live Events'),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.number, required this.label});
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE879F9), Color(0xFFA855F7)],
          ).createShader(bounds),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFA855F7).withValues(alpha: 0.25),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.openExplore});

  final VoidCallback openExplore;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2B104E), Color(0xFF130726), Color(0xFF09040E)],
      ),
      border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFA855F7).withValues(alpha: 0.25),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: openExplore,
      child: Stack(
        children: [
          // Graphic watermark & stars backdrop
          Positioned(
            right: -30,
            top: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 200,
              color: const Color(0xFFA855F7).withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            right: 20,
            top: 16,
            child: Row(
              children: const [
                Text('✦', style: TextStyle(color: Color(0xFFE879F9), fontSize: 16)),
                SizedBox(width: 8),
                Text('✦', style: TextStyle(color: Color(0xFFA855F7), fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Pill(label: '✦ INFINITE POSSIBILITIES ✦'),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: 'The worlds are\n'),
                      TextSpan(
                        text: 'calling you',
                        style: TextStyle(
                          color: Color(0xFFD946EF),
                          shadows: [
                            Shadow(color: Color(0xFFA855F7), blurRadius: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Explore original fandom stories, events, drops & lore',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),

                // Sleek Card Gallery Fan Preview (inspired by reference image)
                SizedBox(
                  height: 90,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.5)),
                            image: const DecorationImage(
                              image: AssetImage(AppAssets.multiverse),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xDD09040E)],
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.bottomLeft,
                            child: const Text(
                              'Multiverse Sagas',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
      ),
      borderRadius: BorderRadius.circular(99),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFA855F7).withValues(alpha: 0.4),
          blurRadius: 8,
        ),
      ],
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 0.6,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onPressed,
  });
  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFC084FC)),
          child: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category, required this.onTap});
  final String category;
  final VoidCallback onTap;

  Map<String, dynamic> _getCategoryStyle(String cat) {
    switch (cat.toLowerCase()) {
      case 'anime':
        return {'icon': Icons.bolt, 'color': const Color(0xFFFFB74D), 'bg': const Color(0xFF2A1505)};
      case 'gaming':
        return {'icon': Icons.sports_esports, 'color': const Color(0xFFE879F9), 'bg': const Color(0xFF2E0938)};
      case 'sci-fi':
        return {'icon': Icons.rocket_launch, 'color': const Color(0xFF38BDF8), 'bg': const Color(0xFF0C1F38)};
      case 'comics':
        return {'icon': Icons.auto_awesome, 'color': const Color(0xFFF43F5E), 'bg': const Color(0xFF330914)};
      case 'fantasy':
        return {'icon': Icons.castle, 'color': const Color(0xFFFACC15), 'bg': const Color(0xFF2E2606)};
      case 'art':
        return {'icon': Icons.palette, 'color': const Color(0xFF2DD4BF), 'bg': const Color(0xFF072B26)};
      default:
        return {'icon': Icons.auto_stories_outlined, 'color': const Color(0xFFA855F7), 'bg': const Color(0xFF1E0C38)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(category);
    final IconData icon = style['icon'] as IconData;
    final Color color = style['color'] as Color;
    final Color bg = style['bg'] as Color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 27,
                backgroundColor: bg,
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  const _StoryCard({required this.item});
  final ContentItem item;

  Map<String, dynamic> _getThemeForItem(ContentItem item) {
    final cat = item.category.toLowerCase();
    switch (cat) {
      case 'anime':
        return {
          'icon': Icons.bolt,
          'gradient': [const Color(0xFF2A1005), const Color(0xFF120602)],
          'accent': const Color(0xFFFFB74D),
        };
      case 'gaming':
        return {
          'icon': Icons.sports_esports,
          'gradient': [const Color(0xFF2B0936), const Color(0xFF12031A)],
          'accent': const Color(0xFFE879F9),
        };
      case 'sci-fi':
        return {
          'icon': Icons.rocket_launch,
          'gradient': [const Color(0xFF091E36), const Color(0xFF030D1A)],
          'accent': const Color(0xFF38BDF8),
        };
      case 'comics':
        return {
          'icon': Icons.auto_awesome,
          'gradient': [const Color(0xFF330914), const Color(0xFF1A030A)],
          'accent': const Color(0xFFF43F5E),
        };
      case 'fantasy':
        return {
          'icon': Icons.castle,
          'gradient': [const Color(0xFF2D1E04), const Color(0xFF140D01)],
          'accent': const Color(0xFFFACC15),
        };
      case 'art':
        return {
          'icon': Icons.palette,
          'gradient': [const Color(0xFF072924), const Color(0xFF021210)],
          'accent': const Color(0xFF2DD4BF),
        };
      default:
        return {
          'icon': Icons.menu_book,
          'gradient': [const Color(0xFF200F38), const Color(0xFF0C0519)],
          'accent': const Color(0xFFA855F7),
        };
    }
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.video:
        return Icons.play_circle_fill;
      case ContentType.podcast:
        return Icons.graphic_eq;
      case ContentType.gallery:
        return Icons.collections;
      case ContentType.news:
        return Icons.newspaper;
      case ContentType.deepDive:
        return Icons.psychology;
      case ContentType.glossary:
        return Icons.menu_book;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref
        .watch(libraryProvider)
        .bookmarkedContent
        .contains(item.id);

    final theme = _getThemeForItem(item);
    final List<Color> colors = theme['gradient'] as List<Color>;
    final Color accent = theme['accent'] as Color;
    final IconData categoryIcon = theme['icon'] as IconData;
    final IconData typeIcon = _getTypeIcon(item.type);
    final bool hasCustomImage = isHttpsMediaUrl(item.imageUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContentDetailScreen(item: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCustomImage) ...[
              RemoteMediaImage(url: item.imageUrl!),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xF209040E)],
                    stops: [0.2, 1.0],
                  ),
                ),
              ),
            ] else ...[
              // Themed Background Watermark Graphic
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  categoryIcon,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.88)],
                  ),
                ),
              ),
            ],

            // Content Padding & Badges
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: accent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, size: 11, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              item.type.name.toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        tooltip: bookmarked ? 'Remove bookmark' : 'Save offline',
                        onPressed: () => ref
                            .read(libraryProvider.notifier)
                            .toggleBookmark(item.id, item: item),
                        icon: Icon(
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 17,
                          color: bookmarked ? const Color(0xFFE879F9) : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.account_circle, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.creator,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingFandomCarousel extends StatefulWidget {
  const _TrendingFandomCarousel();

  @override
  State<_TrendingFandomCarousel> createState() =>
      _TrendingFandomCarouselState();
}

class _TrendingFandomCarouselState extends State<_TrendingFandomCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const _trendingCards = [
    {
      'fandom': 'Anime',
      'title': 'Shinobi Rising & New Seasons',
      'tag': '#1 TRENDING UNIVERSE',
      'desc':
          'Explore original ninja sagas, creator profiles, and combat galleries.',
      'gradient': [Color(0xFF380E05), Color(0xFF140502)],
      'icon': Icons.bolt,
    },
    {
      'fandom': 'Gaming',
      'title': 'Arena Champions 2026',
      'tag': '#2 TRENDING UNIVERSE',
      'desc':
          'Esports brackets, speedrunning lore, and competitive cyberpunk arenas.',
      'gradient': [Color(0xFF38084A), Color(0xFF14021C)],
      'icon': Icons.sports_esports,
    },
    {
      'fandom': 'Comics',
      'title': 'Marvel Multiverse Incursion',
      'tag': '#3 TRENDING UNIVERSE',
      'desc':
          'Parallel variant timelines, superhero covers, and cosmic crossover events.',
      'gradient': [Color(0xFF3D080E), Color(0xFF170205)],
      'icon': Icons.auto_awesome,
    },
    {
      'fandom': 'Sci-Fi',
      'title': 'Starship Odyssey Chronicles',
      'tag': '#4 TRENDING UNIVERSE',
      'desc':
          'Deep space precursor arks, warp drive physics, and alien homeworlds.',
      'gradient': [Color(0xFF092040), Color(0xFF030C1C)],
      'icon': Icons.rocket_launch,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.local_fire_department,
              color: Color(0xFFD946EF),
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              'Trending Fandoms Carousel',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: _trendingCards.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final card = _trendingCards[index];
              final gradient = card['gradient'] as List<Color>;
              final icon = card['icon'] as IconData;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExploreScreen(
                        initialCategory: card['fandom'] as String,
                        standalone: true,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: const Color(0xFFD946EF).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                card['tag'] as String,
                                style: const TextStyle(
                                  color: Color(0xFFE879F9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(icon, color: const Color(0xFFC084FC), size: 20),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          card['fandom'] as String,
                          style: const TextStyle(
                            color: Color(0xFFD946EF),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          card['title'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card['desc'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _trendingCards.length,
            (idx) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == idx ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == idx
                    ? const Color(0xFFA855F7)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HubQuickCards extends StatelessWidget {
  const _HubQuickCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BeginnerHubScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D0D36), Color(0xFF100622)],
                ),
                border: Border.all(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.eco, size: 20),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Beginner Hub 🌱',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Terminology glossary, profiles & stories for new fans.',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DeepDiveScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B0A42), Color(0xFF160326)],
                ),
                border: Border.all(
                  color: const Color(0xFFD946EF).withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD946EF).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.psychology, size: 20),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Deep Dive 🧠',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hidden trivia, advanced lore & creator interviews.',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CuratedMiniCard extends StatelessWidget {
  const _CuratedMiniCard({required this.item});

  final ContentItem item;

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'anime':
        return const Color(0xFFFFB74D);
      case 'gaming':
        return const Color(0xFFE879F9);
      case 'sci-fi':
        return const Color(0xFF38BDF8);
      case 'comics':
        return const Color(0xFFF43F5E);
      case 'fantasy':
        return const Color(0xFFFACC15);
      case 'art':
        return const Color(0xFF2DD4BF);
      default:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(item.category);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContentDetailScreen(item: item),
        ),
      ),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF160B28),
          border: Border.all(color: catColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: catColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: catColor,
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.2, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'By ${item.creator}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
