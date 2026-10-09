import 'package:flutter/material.dart';

import '../domain/character_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({super.key, required this.character});

  final Character character;

  Color get _accentColor {
    switch (character.characterType.toLowerCase()) {
      case 'anime character':
        return const Color(0xFFE879F9);
      case 'marvel superhero':
        return const Color(0xFFA855F7);
      case 'dc superhero':
        return const Color(0xFFC084FC);
      case 'star wars character':
        return const Color(0xFFD946EF);
      default:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Full-bleed Hero ───
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background gradient scene
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.3),
                            radius: 1.2,
                            colors: [
                              accent.withValues(alpha: 0.4),
                              const Color(0xFF09040E),
                            ],
                          ),
                        ),
                      ),
                      // Character image
                      character.imageAsset.startsWith('http')
                          ? Image.network(
                              character.imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            )
                          : Image.asset(
                              character.imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                      // Bottom gradient to blend into content
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 150,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xFF09040E),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Info Content ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and Title Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Floating Avatar (Using a crop of the character)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF160B28),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: character.imageAsset.startsWith('http')
                                ? Image.network(character.imageAsset,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter)
                                : Image.asset(character.imageAsset,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          color: Colors.white, size: 10),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        character.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFD740), size: 14),
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFD740), size: 14),
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFD740), size: 14),
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFD740), size: 14),
                                    const Icon(Icons.star_half,
                                        color: Color(0xFFFFD740), size: 14),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${character.fandom}  ›  ${character.characterType}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(
                                            alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chips Row
                      Row(
                        children: [
                          _DetailChip(label: '#${character.popularityOrder} Popular'),
                          const SizedBox(width: 10),
                          _DetailChip(label: 'Trending'),
                          const SizedBox(width: 10),
                          _DetailChip(label: 'Verified'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // About Section
                      const Text(
                        'About Character',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.6,
                          ),
                          children: [
                            TextSpan(text: character.description),
                            const TextSpan(
                              text: ' ... ',
                            ),
                            TextSpan(
                              text: 'Read More',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatColumn(
                              icon: Icons.people_alt_outlined,
                              value: '1.2M',
                              label: 'Followers',
                              accentColor: accent),
                          _StatColumn(
                              icon: Icons.person_outline,
                              value: '45.5m',
                              label: 'Fans',
                              accentColor: accent),
                          _StatColumn(
                              icon: Icons.cell_tower,
                              value: '20.4k',
                              label: 'Posts',
                              accentColor: accent),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Floating Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _BookmarkButton(character: character, accentColor: accent),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets for detail screen
// ─────────────────────────────────────────────────────────────────────────────

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor.withValues(alpha: 0.8), size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BookmarkButton extends StatefulWidget {
  const _BookmarkButton({required this.character, required this.accentColor});
  final Character character;
  final Color accentColor;

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _saved = !_saved);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_saved
              ? '${widget.character.name} bookmarked!'
              : 'Bookmark removed'),
          backgroundColor: widget.accentColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        decoration: BoxDecoration(
          color: _saved ? widget.accentColor : const Color(0xFFC084FC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_saved ? widget.accentColor : const Color(0xFFC084FC))
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _saved ? 'Added to Bookmarks' : 'Bookmark Character',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Popular Characters Section (Home Page)
// ─────────────────────────────────────────────────────────────────────────────

class PopularCharactersSection extends StatelessWidget {
  const PopularCharactersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final popular = [...popularCharacters]
      ..sort((a, b) => a.popularityOrder.compareTo(b.popularityOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFD740), Color(0xFFFF8C00)],
              ).createShader(bounds),
              child: const Icon(Icons.star_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Popular Characters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _AllCharactersScreen(characters: popular),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C0D38),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFFC084FC),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 10, color: Color(0xFFC084FC)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Horizontal 3D Cover Flow Carousel
        SizedBox(
          height: 280,
          child: _CoverFlowCarousel(characters: popular),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Character Card — Premium Glassmorphism Design
// ─────────────────────────────────────────────────────────────────────────────

class _CharacterCard extends StatefulWidget {
  const _CharacterCard({required this.character});
  final Character character;

  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  Color get _accentColor {
    switch (widget.character.characterType.toLowerCase()) {
      case 'anime character':
        return const Color(0xFFE879F9);
      case 'marvel superhero':
        return const Color(0xFFA855F7);
      case 'dc superhero':
        return const Color(0xFFC084FC);
      case 'star wars character':
        return const Color(0xFFD946EF);
      default:
        return const Color(0xFFA855F7);
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _liked = !_liked);
    _animController.forward().then((_) => _animController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              CharacterDetailScreen(character: widget.character),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2D1154),
                      const Color(0xFF0C0519),
                    ],
                  ),
                ),
              ),

              // Character image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: widget.character.imageAsset.startsWith('http')
                    ? Image.network(
                        widget.character.imageAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.person,
                              color: accent.withValues(alpha: 0.4), size: 70),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: accent,
                                strokeWidth: 2.5,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.character.imageAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.person,
                              color: accent.withValues(alpha: 0.4), size: 70),
                        ),
                      ),
              ),

              // Bottom gradient for text legibility
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.92),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Top: Popular badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD740), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          size: 9, color: Colors.black87),
                      SizedBox(width: 3),
                      Text(
                        'POPULAR',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top: Like button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1),
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Icon(
                          _liked ? Icons.favorite_rounded : Icons.favorite_border,
                          size: 15,
                          color: _liked
                              ? const Color(0xFFFF4081)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom: Name + fandom
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.character.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.character.fandom,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All Characters Grid Screen
// ─────────────────────────────────────────────────────────────────────────────

class _AllCharactersScreen extends StatelessWidget {
  const _AllCharactersScreen({required this.characters});
  final List<Character> characters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0519),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFFFD740), size: 20),
            SizedBox(width: 8),
            Text('Popular Characters',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        leading: const BackButton(),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 165 / 250,
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) =>
            _CharacterCard(character: characters[index]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3D Cover Flow Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _CoverFlowCarousel extends StatefulWidget {
  const _CoverFlowCarousel({required this.characters});
  final List<Character> characters;

  @override
  State<_CoverFlowCarousel> createState() => _CoverFlowCarouselState();
}

class _CoverFlowCarouselState extends State<_CoverFlowCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.characters.length,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = index - _currentPage;
        } else {
          value = (index == 0) ? 0.0 : 1.0;
        }

        // Clamp the value to ensure rotation doesn't go crazy
        final clampedValue = value.clamp(-1.0, 1.0);

        // Rotation: 
        // if clampedValue < 0 (left card), we rotate negative so right edge is closer
        // if clampedValue > 0 (right card), we rotate positive so left edge is closer
        final double rotationY = clampedValue * 0.6; // approx 35 degrees

        // Scale: Center card is 1.0, side cards shrink down slightly
        final double scale = 1 - (clampedValue.abs() * 0.15);

        // Translate: Pull side cards slightly inwards to make them overlap nicely
        // A negative translation pulls right card left, positive pulls left card right
        final double translateX = clampedValue * -20.0;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..translate(translateX, 0.0, 0.0)
            ..rotateY(rotationY)
            ..scale(scale, scale),
          alignment: Alignment.center,
          child: _CharacterCard(character: widget.characters[index]),
        );
      },
    );
  }
}
