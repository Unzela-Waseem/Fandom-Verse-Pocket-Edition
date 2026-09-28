import 'package:flutter/material.dart';

import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';

class CharacterProfile {
  const CharacterProfile({
    required this.name,
    required this.fandom,
    required this.role,
    required this.tagline,
    required this.bio,
    required this.image,
    required this.gallery,
    required this.color,
    required this.traits,
  });

  final String name;
  final String fandom;
  final String role;
  final String tagline;
  final String bio;
  final String image;
  final List<String> gallery;
  final Color color;
  final List<String> traits;
}

const characterProfiles = [
  CharacterProfile(
    name: 'Iron Guardian',
    fandom: 'Marvel Universe',
    role: 'Tech hero',
    tagline: 'Genius, courage and a suit built for impossible missions.',
    bio: 'A fan-made profile celebrating the technology, sacrifice and sharp wit that make modern superhero stories so memorable.',
    image: 'assets/avengers.jpeg',
    gallery: ['assets/avengers.jpeg', 'assets/images/fandom_multiverse.png', 'assets/trending_comics.jpg'],
    color: Color(0xFFE85D75),
    traits: ['Technology', 'Leadership', 'Courage'],
  ),
  CharacterProfile(
    name: 'Shield Sentinel',
    fandom: 'Marvel Universe',
    role: 'Team leader',
    tagline: 'A steady shield, a stronger promise and a team to protect.',
    bio: 'Explore the ideals, friendships and iconic team moments behind a classic comic-book leader.',
    image: 'assets/avengers.jpeg',
    gallery: ['assets/avengers.jpeg', 'assets/trending_comics.jpg', 'assets/images/cosmic_wallpaper.jpg'],
    color: Color(0xFF4D8DFF),
    traits: ['Duty', 'Teamwork', 'Honor'],
  ),
  CharacterProfile(
    name: 'Hidden Leaf Ninja',
    fandom: 'Anime & Manga',
    role: 'Shinobi hero',
    tagline: 'Turn setbacks into strength and never abandon your crew.',
    bio: 'A visual anime profile for fans who love training arcs, found family and the courage to write their own path.',
    image: 'assets/ninja.jpg',
    gallery: ['assets/ninja.jpg', 'assets/trending_anime.jpg', 'assets/media/anime_sketchbook.webp'],
    color: Color(0xFFFF8A5B),
    traits: ['Resilience', 'Focus', 'Friendship'],
  ),
  CharacterProfile(
    name: 'Arena Vanguard',
    fandom: 'Gaming Worlds',
    role: 'Squad captain',
    tagline: 'Read the arena, support your squad and make the next move count.',
    bio: 'A gaming character hub for strategy fans, squad leaders and players who turn every match into a story.',
    image: 'assets/gaming.jpg',
    gallery: ['assets/gaming.jpg', 'assets/media/gaming_squad.webp', 'assets/media/gaming_gallery.webp'],
    color: Color(0xFF56D6C0),
    traits: ['Strategy', 'Reflexes', 'Squad play'],
  ),
  CharacterProfile(
    name: 'Cosmic Wayfinder',
    fandom: 'Sci-Fi Worlds',
    role: 'Explorer',
    tagline: 'Every signal is a story waiting to be discovered.',
    bio: 'Step into a science-fiction profile filled with distant signals, small worlds and big questions about the future.',
    image: 'assets/images/cosmic_wallpaper.jpg',
    gallery: ['assets/images/cosmic_wallpaper.jpg', 'assets/media/scifi_orbit.webp', 'assets/media/scifi_gallery.webp'],
    color: Color(0xFF9A7BFF),
    traits: ['Discovery', 'Curiosity', 'Worldbuilding'],
  ),
  CharacterProfile(
    name: 'Gotham Nightwatch',
    fandom: 'Comics & Graphic Worlds',
    role: 'Detective hero',
    tagline: 'Look closer. The smallest clue can change the whole story.',
    bio: 'A comics-inspired profile about detective work, visual storytelling and the atmosphere that makes graphic worlds unforgettable.',
    image: 'assets/trending_comics.jpg',
    gallery: ['assets/trending_comics.jpg', 'assets/media/comics_panels.webp', 'assets/media/comics_covers.webp'],
    color: Color(0xFF7D9AC7),
    traits: ['Mystery', 'Discipline', 'Ingenuity'],
  ),
];

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      appBar: AppBar(
        title: const Text('Character Hub'),
        backgroundColor: const Color(0xFF0C0616),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade300),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HubHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent >= 950
                    ? 3
                    : constraints.crossAxisExtent >= 560
                        ? 2
                        : 1;
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CharacterCard(profile: characterProfiles[index]),
                    childCount: characterProfiles.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 1.65 : 1.05,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1454), Color(0xFF111126)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEET THE UNIVERSES', style: TextStyle(color: Color(0xFFD8B4FE), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          SizedBox(height: 9),
          Text('Characters, all in one place', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
          SizedBox(height: 8),
          Text('Open a profile to explore its story, gallery, news and fandom details together.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.profile});
  final CharacterProfile profile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CharacterDetailScreen(profile: profile))),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF160B28),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: profile.color.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(profile.image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fandom.toUpperCase(), style: TextStyle(color: profile.color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(profile.role, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Positioned(right: 14, top: 14, child: CircleAvatar(radius: 16, backgroundColor: Color(0xAA0C0616), child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17))),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({super.key, required this.profile});
  final CharacterProfile profile;

  @override
  Widget build(BuildContext context) {
    final fandomKey = switch (profile.fandom) {
      'Marvel Universe' => 'comics',
      'Anime & Manga' => 'anime',
      'Gaming Worlds' => 'gaming',
      'Sci-Fi Worlds' => 'sci-fi',
      _ => profile.fandom.split(' ').first.toLowerCase(),
    };
    final related = contentCatalog
        .where((item) => item.category.toLowerCase().contains(fandomKey))
        .take(6)
        .toList();
    final news = related.where((item) => item.type == ContentType.story || item.type == ContentType.news).toList();
    final gallery = related.where((item) => item.type == ContentType.gallery).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0C0616),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w800, shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(profile.image, fit: BoxFit.cover),
                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, const Color(0xFF09040E).withValues(alpha: 0.95)]))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
            sliver: SliverList.list(children: [
              Text(profile.fandom.toUpperCase(), style: TextStyle(color: profile.color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
              const SizedBox(height: 8),
              Text(profile.tagline, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 12),
              Text(profile.bio, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
              const SizedBox(height: 18),
              Wrap(spacing: 8, runSpacing: 8, children: profile.traits.map((trait) => Chip(label: Text(trait), backgroundColor: profile.color.withValues(alpha: 0.15), side: BorderSide(color: profile.color.withValues(alpha: 0.35)), labelStyle: const TextStyle(color: Colors.white, fontSize: 12))).toList()),
              const SizedBox(height: 28),
              _DetailHeading(title: 'Gallery', icon: Icons.photo_library_outlined, count: profile.gallery.length),
              const SizedBox(height: 12),
              SizedBox(height: 130, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: profile.gallery.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) => ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(profile.gallery[index], width: 190, fit: BoxFit.cover)))),
              const SizedBox(height: 28),
              _DetailHeading(title: 'Latest news & stories', icon: Icons.newspaper_outlined, count: news.length),
              const SizedBox(height: 12),
              if (news.isEmpty) const _EmptySection(text: 'New stories for this universe are coming soon.') else ...news.map((item) => _RelatedContentCard(item: item)),
              const SizedBox(height: 18),
              _DetailHeading(title: 'Explore this fandom', icon: Icons.auto_awesome_outlined, count: gallery.length),
              const SizedBox(height: 12),
              if (related.isEmpty) const _EmptySection(text: 'Explore more fan-made stories and guides soon.') else ...related.map((item) => _RelatedContentCard(item: item)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DetailHeading extends StatelessWidget {
  const _DetailHeading({required this.title, required this.icon, required this.count});
  final String title; final IconData icon; final int count;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: const Color(0xFFD8B4FE), size: 21), const SizedBox(width: 9), Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(width: 8), Text('$count', style: const TextStyle(color: Colors.white38, fontSize: 13))]);
}

class _RelatedContentCard extends StatelessWidget {
  const _RelatedContentCard({required this.item});
  final ContentItem item;
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF160B28),
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0x3326113D))),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 62, height: 62, child: item.imageUrl == null ? const ColoredBox(color: Color(0xFF2A1154), child: Icon(Icons.auto_awesome, color: Colors.white54)) : Image.asset(item.imageUrl!, fit: BoxFit.cover))),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
    ),
  );
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF160B28), borderRadius: BorderRadius.circular(16)), child: Text(text, style: const TextStyle(color: Colors.white60)));
}

class CharacterHubBanner extends StatelessWidget {
  const CharacterHubBanner({super.key});
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CharactersScreen())),
    child: Ink(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF30155F), Color(0xFF15102B)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35))),
      child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFFA855F7), child: Icon(Icons.groups_rounded, color: Colors.white)), SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Character Hub', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Open character profiles, galleries and news in one place.', style: TextStyle(color: Colors.white70, fontSize: 12))])), Icon(Icons.arrow_forward_rounded, color: Colors.white70)]),
    ),
  );
}
