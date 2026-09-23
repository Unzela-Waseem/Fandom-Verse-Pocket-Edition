import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../authentication/domain/app_user.dart';
import '../domain/fandom_item.dart';

class FanShell extends StatefulWidget {
  const FanShell({super.key, this.profile});

  final AppUser? profile;

  @override
  State<FanShell> createState() => _FanShellState();
}

class _FanShellState extends State<FanShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(profile: widget.profile),
      const _ExploreTab(),
      const _EventsTab(),
      const _StoreTab(),
      const _ProfileTab(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 68,
        backgroundColor: const Color(0xFF17171C),
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) => setState(() => _index = value),
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
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({this.profile});

  final AppUser? profile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverList.list(
              children: [
                _TopBar(profile: profile),
                const SizedBox(height: 24),
                const _HeroCard(),
                const SizedBox(height: 28),
                const _SectionTitle(title: 'Live now', action: 'View all'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: demoFandoms.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (_, index) =>
                        _LiveAvatar(item: demoFandoms[index]),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  title: 'Recommended for you',
                  action: 'See more',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.builder(
              itemCount: demoFandoms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: .76,
              ),
              itemBuilder: (_, index) => _FandomCard(item: demoFandoms[index]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.profile});

  final AppUser? profile;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        const SizedBox(width: 6),
        Badge(
          smallSize: 8,
          child: IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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
                  const _Pill(label: 'TRENDING UNIVERSE'),
                  const SizedBox(height: 10),
                  Text(
                    'The worlds are\ncalling you',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 17,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '48.2K fans exploring',
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
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});
  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class _LiveAvatar extends StatelessWidget {
  const _LiveAvatar({required this.item});
  final FandomItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: item.color, width: 2),
            ),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: const Color(0xFF24232B),
              child: Icon(item.icon, color: item.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FandomCard extends StatelessWidget {
  const _FandomCard({required this.item});
  final FandomItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => _FandomDetail(item: item)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: DecorationImage(
            image: const AssetImage(AppAssets.multiverse),
            fit: BoxFit.cover,
            alignment: item.alignment,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
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
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border, size: 19),
                ),
              ),
              const Spacer(),
              Text(
                item.category.toUpperCase(),
                style: TextStyle(
                  color: item.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFD740), size: 15),
                  SizedBox(width: 4),
                  Text('4.9', style: TextStyle(fontSize: 11)),
                  Spacer(),
                  Text(
                    '12K fans',
                    style: TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FandomDetail extends StatelessWidget {
  const _FandomDetail({required this.item});
  final FandomItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 330,
            pinned: true,
            actions: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.multiverse,
                    fit: BoxFit.cover,
                    alignment: item.alignment,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF101014)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'Featured stories',
                  action: 'View all',
                ),
                ...List.generate(
                  3,
                  (index) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: item.color.withValues(alpha: .18),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(
                      [
                        'A beginner’s guide to the universe',
                        'Seven details fans almost missed',
                        'Creators share behind-the-scenes stories',
                      ][index],
                    ),
                    subtitle: Text('${4 + index} min read · Available offline'),
                    trailing: const Icon(Icons.chevron_right),
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

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();
  @override
  Widget build(BuildContext context) => const _SimpleTab(
    title: 'Explore',
    subtitle: 'Find stories, lore, profiles, podcasts, and hidden trivia.',
    icon: Icons.explore_outlined,
    chips: ['All', 'Anime', 'Gaming', 'Sci-Fi', 'Fantasy', 'Comics', 'Music'],
  );
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();
  @override
  Widget build(BuildContext context) => const _SimpleTab(
    title: 'Events near you',
    subtitle: 'Browse conventions and meetups without sharing your location.',
    icon: Icons.location_on_outlined,
    chips: ['Upcoming', 'Karachi', 'Lahore', 'Islamabad', 'Online'],
  );
}

class _StoreTab extends StatelessWidget {
  const _StoreTab();
  @override
  Widget build(BuildContext context) => const _SimpleTab(
    title: 'Fan store',
    subtitle:
        'Official-style collectibles, apparel, and digital assets. Demo checkout only.',
    icon: Icons.shopping_bag_outlined,
    chips: ['Featured', 'Apparel', 'Collectibles', 'Digital'],
  );
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const _SimpleTab(
    title: 'Your profile',
    subtitle:
        'Manage fandoms, bookmarks, offline content, wishlist, and purchases.',
    icon: Icons.person_outline,
    chips: ['Bookmarks', 'Offline', 'Wishlist', 'Purchases'],
  );
}

class _SimpleTab extends StatelessWidget {
  const _SimpleTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.chips,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 22),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search $title',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.tune),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (label) => FilterChip(label: Text(label), onSelected: (_) {}),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ...demoFandoms
              .take(3)
              .map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
