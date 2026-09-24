import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../authentication/domain/app_user.dart';
import '../../events/presentation/events_screen.dart';
import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';
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
    if (widget.profile != null && !kIsWeb) {
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
    if (kIsWeb) return;
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
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (value) =>
                          setState(() => _index = value),
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: const Color(0xFF17171C),
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
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: IndexedStack(index: _index, children: pages),
                    ),
                  ],
                )
              : IndexedStack(index: _index, children: pages),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  height: 68,
                  backgroundColor: const Color(0xFF17171C),
                  indicatorColor: Theme.of(context).colorScheme.primary,
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverList.list(
              children: [
                _TopBar(profile: profile, openExplore: openExplore),
                const SizedBox(height: 24),
                _HeroCard(openExplore: openExplore),
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Explore fandoms',
                  action: 'View all',
                  onPressed: openExplore,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (_, index) => _CategoryAvatar(
                      category: categories[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ExploreScreen(initialCategory: categories[index]),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Featured stories',
                  action: 'See more',
                  onPressed: openExplore,
                ),
                const SizedBox(height: 12),
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
                childAspectRatio: .76,
              ),
              itemBuilder: (_, index) => _StoryCard(item: featured[index]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
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
      const CircleAvatar(
        radius: 22,
        backgroundColor: Color(0xFF332C4D),
        child: Icon(Icons.person, color: Colors.white70),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              profile?.displayName ?? 'Fandom Explorer',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ),
      IconButton.filledTonal(
        tooltip: 'Explore and search',
        onPressed: openExplore,
        icon: const Icon(Icons.search),
      ),
      const SizedBox(width: 6),
      IconButton.filledTonal(
        tooltip: 'Notifications',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
        ),
        icon: const Icon(Icons.notifications_none),
      ),
    ],
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.openExplore});

  final VoidCallback openExplore;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.18,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Material(
        child: InkWell(
          onTap: openExplore,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppAssets.multiverse, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xEE08080B)],
                    stops: [.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Pill(label: 'DISCOVER YOUR NEXT STORY'),
                    const SizedBox(height: 10),
                    Text(
                      'The worlds are\ncalling you',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          'Explore original fandom stories',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundColor: Color(0xFFFFD740),
                          child: Icon(Icons.arrow_forward, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w900,
        fontSize: 10,
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
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
      ),
      TextButton(onPressed: onPressed, child: Text(action)),
    ],
  );
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category, required this.onTap});
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD740), width: 2),
            ),
            child: const CircleAvatar(
              radius: 27,
              backgroundColor: Color(0xFF24232B),
              child: Icon(
                Icons.auto_stories_outlined,
                color: Color(0xFFFFD740),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _StoryCard extends ConsumerWidget {
  const _StoryCard({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref
        .watch(libraryProvider)
        .bookmarkedContent
        .contains(item.id);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContentDetailScreen(item: item),
        ),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          image: DecorationImage(
            image: AssetImage(AppAssets.multiverse),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xF20A0A0E)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  tooltip: bookmarked ? 'Remove bookmark' : 'Save offline',
                  onPressed: () => ref
                      .read(libraryProvider.notifier)
                      .toggleBookmark(item.id, item: item),
                  icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 19,
                  ),
                ),
              ),
              const Spacer(),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'By ${item.creator}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
