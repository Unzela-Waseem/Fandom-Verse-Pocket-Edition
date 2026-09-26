import 'package:flutter/material.dart';
import '../../authentication/presentation/landing_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const List<_SlideData> _slides = [
    _SlideData(
      image: 'assets/premium_bg.jpg',
      badge: 'FANDOM VERSE',
      title: 'Welcome to\nFandom Verse',
      features: [
        'Anime and Manga Hub with Characters and Sagas',
        'Explore iconic series lore and fan theories',
        'Community discussions and fan art gallery',
        'Bookmark your favourite characters and series',
      ],
      accentColor: Color(0xFFA855F7),
      gradientColors: [Color(0xCC08061A), Color(0xFF08061A)],
    ),
    _SlideData(
      image: 'assets/slide2_gaming.png',
      badge: 'GAMING AND ESPORTS',
      title: 'Dominate the\nArena',
      features: [
        'Live Esports brackets and tournament updates',
        'Speedrunning routes and pro gaming guides',
        'DLC walkthroughs and retro gaming lore',
        'Connect with gamers from your fandom',
      ],
      accentColor: Color(0xFFAB47BC),
      gradientColors: [Color(0xCC0A0018), Color(0xFF0A0018)],
    ),
    _SlideData(
      image: 'assets/slide3_ai.jpg',
      badge: 'AI AND EVENTS',
      title: 'Your Fandom\nAssistant',
      features: [
        'AI Fan Helper answers any fandom question',
        'GPS-based Fandom Events Map near you',
        'Get notified about fan meetups and expos',
        'Navigate event venues with Google Maps',
      ],
      accentColor: Color(0xFF29B6F6),
      gradientColors: [Color(0xCC020818), Color(0xFF020818)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const LandingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08061A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              return _SlideView(slide: _slides[index]);
            },
          ),
          // Skip button top right
          Positioned(
            top: 52,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: _onFinish,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            left: 28,
            right: 28,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CTA button
                    _NextButton(
                      label: _currentPage == _slides.length - 1
                          ? "Get Started - It's Free"
                          : 'Continue',
                      accentColor: _slides[_currentPage].accentColor,
                      onTap: _onNext,
                    ),
                    const SizedBox(height: 20),
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (idx) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == idx ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == idx
                                ? _slides[_currentPage].accentColor
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Footer links
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(label: 'Terms of use'),
                        _Dot(),
                        _FooterLink(label: 'Privacy Policy'),
                        _Dot(),
                        _FooterLink(label: 'Restore'),
                      ],
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

// ── Data model ─────────────────────────────────────────────────────────────
class _SlideData {
  final String image;
  final String badge;
  final String title;
  final List<String> features;
  final Color accentColor;
  final List<Color> gradientColors;

  const _SlideData({
    required this.image,
    required this.badge,
    required this.title,
    required this.features,
    required this.accentColor,
    required this.gradientColors,
  });
}

// ── Single slide view ───────────────────────────────────────────────────────
class _SlideView extends StatefulWidget {
  final _SlideData slide;
  const _SlideView({required this.slide});

  @override
  State<_SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<_SlideView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        // Top vignette
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Bottom gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                slide.gradientColors[0],
                slide.gradientColors[1],
              ],
              stops: const [0.3, 0.6, 0.8],
            ),
          ),
        ),
        // Content
        Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.5)),
                        color: slide.accentColor.withValues(alpha: 0.12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: slide.accentColor, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            slide.badge,
                            style: TextStyle(
                              color: slide.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Feature list
                    ...slide.features.map(
                      (f) => _FeatureItem(label: f, accentColor: slide.accentColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feature item ───────────────────────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.label, required this.accentColor});
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: Icon(Icons.check, size: 12, color: accentColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA button ─────────────────────────────────────────────────────────────
class _NextButton extends StatefulWidget {
  const _NextButton({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor,
                widget.accentColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────
class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white38, fontSize: 11),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text('.', style: TextStyle(color: Colors.white24, fontSize: 11)),
    );
  }
}