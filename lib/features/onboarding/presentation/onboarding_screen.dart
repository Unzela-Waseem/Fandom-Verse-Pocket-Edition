import 'package:flutter/material.dart';

import '../../../core/widgets/premium_layout.dart';
import '../../authentication/presentation/login_screen.dart';
import '../../dashboard/presentation/privacy_policy_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      image: 'assets/premium_bg.jpg',
      label: 'DISCOVER YOUR NEXT OBSESSION',
      title: 'Welcome to\nFandom Verse.',
      description: 'A little closer to the worlds you love.',
      features: [
        'Explore stories, characters and hidden lore',
        'Find your community and share fan theories',
        'Save your favourites in your personal library'
      ],
      icon: Icons.auto_awesome_outlined,
    ),
    (
      image: 'assets/slide3_ai.jpg',
      label: 'MORE THAN A FEED',
      title: 'Find your people.\nLive your fandom.',
      description: 'Discover something worth getting excited about.',
      features: [
        'Explore fandom topics with your AI Fan Helper',
        'Discover conventions and local fan meetups',
        'Find your way with event maps and directions'
      ],
      icon: Icons.explore_outlined,
    ),
    (
      image: 'assets/slide2_gaming.png',
      label: 'ENTER THE MULTIVERSE',
      title: 'Your worlds.\nOne universe.',
      description:
          'Stories, events, communities and collectibles. All together, all yours to explore.',
      features: <String>[],
      icon: Icons.bolt_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    }
  }

  void _login(bool admin) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => LoginScreen(adminMode: admin)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF08061A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                final last = index == _slides.length - 1;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(slide.image,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Color(0xFF211039))),
                    const DecoratedBox(
                        decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x6606040F),
                            Color(0x3306040F),
                            Color(0xEE06040F)
                          ]),
                    )),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 900;
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: Align(
                                alignment: wide
                                    ? Alignment.center
                                    : Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.all(wide ? 40 : 20),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 1160),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (wide) ...[
                                          const Expanded(
                                              child: _DesktopIntroduction()),
                                          const SizedBox(width: 64),
                                        ],
                                        Flexible(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 520),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    wide ? 32 : 22),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(children: [
                                                      Icon(slide.icon,
                                                          color: const Color(
                                                              0xFFD8B4FE),
                                                          size: 20),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                          child: Text(
                                                              slide.label,
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  letterSpacing:
                                                                      1.6,
                                                                  color: Color(
                                                                      0xFFE9D5FF)))),
                                                    ]),
                                                    const SizedBox(height: 22),
                                                    Text(slide.title,
                                                        style: TextStyle(
                                                            fontSize:
                                                                wide ? 38 : 30,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            height: 1.12,
                                                            letterSpacing: -.9,
                                                            color:
                                                                Colors.white)),
                                                    const SizedBox(height: 14),
                                                    Text(slide.description,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFFD3CDDD),
                                                            height: 1.6)),
                                                    const SizedBox(height: 24),
                                                    for (final feature
                                                        in slide.features)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 14),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  size: 18,
                                                                  color: Color(
                                                                      0xFFD8B4FE)),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                  child: Text(
                                                                      feature,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .white,
                                                                          height:
                                                                              1.5))),
                                                            ]),
                                                      ),
                                                    if (!last)
                                                      const SizedBox(
                                                          height: 10),
                                                    FilledButton.icon(
                                                      onPressed: () => last
                                                          ? _login(false)
                                                          : _goTo(index + 1),
                                                      label: Text(
                                                          last
                                                              ? 'Continue as a fan'
                                                              : 'Continue',
                                                          textAlign:
                                                              TextAlign.center),
                                                      icon: const Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          size: 18),
                                                      iconAlignment:
                                                          IconAlignment.end,
                                                    ),
                                                    if (last) ...[
                                                      const SizedBox(height: 8),
                                                      TextButton.icon(
                                                          onPressed: () =>
                                                              _login(true),
                                                          icon: const Icon(
                                                              Icons
                                                                  .shield_outlined,
                                                              size: 17),
                                                          label: const Text(
                                                              'Admin sign in')),
                                                    ],
                                                    const SizedBox(height: 16),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: List.generate(
                                                            _slides.length,
                                                            (dot) => Semantics(
                                                                  label:
                                                                      'Page ${dot + 1} of ${_slides.length}',
                                                                  selected:
                                                                      dot ==
                                                                          index,
                                                                  child: SizedBox(
                                                                      width: 36,
                                                                      height: 32,
                                                                      child: IconButton(
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        tooltip:
                                                                            'Go to page ${dot + 1}',
                                                                        onPressed:
                                                                            () =>
                                                                                _goTo(dot),
                                                                        icon: AnimatedContainer(
                                                                            duration:
                                                                                const Duration(milliseconds: 200),
                                                                            width: dot == index ? 24 : 6,
                                                                            height: 6,
                                                                            decoration: BoxDecoration(color: dot == index ? const Color(0xFFD8B4FE) : Colors.white30, borderRadius: BorderRadius.circular(8))),
                                                                      )),
                                                                ))),
                                                    Center(
                                                        child: TextButton(
                                                            onPressed: () => Navigator
                                                                    .of(context)
                                                                .push(MaterialPageRoute<
                                                                        void>(
                                                                    builder: (_) =>
                                                                        const PrivacyPolicyScreen())),
                                                            child: const Text(
                                                                'Privacy policy',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white70,
                                                                    fontSize:
                                                                        12)))),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(children: [
                        const Expanded(
                            child: Text('FANDOM VERSE',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: Colors.white))),
                        if (_page < _slides.length - 1)
                          GlassPanel(
                              radius: 30,
                              padding: EdgeInsets.zero,
                              child: TextButton(
                                  onPressed: () => _goTo(_slides.length - 1),
                                  child: const Text('Skip',
                                      style: TextStyle(color: Colors.white)))),
                      ])),
                )),
          ],
        ),
      );
}

class _DesktopIntroduction extends StatelessWidget {
  const _DesktopIntroduction();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('A SPACE FOR EVERY FAN',
              style: TextStyle(
                  color: Color(0xFFE9D5FF),
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 20),
          Text('Make room\nfor wonder.',
              style: TextStyle(
                  fontSize: 64,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: Colors.white)),
          SizedBox(height: 24),
          Text('DISCOVER  /  CONNECT  /  COLLECT',
              style: TextStyle(
                  fontSize: 11, letterSpacing: 2, color: Colors.white70)),
        ],
      );
}
