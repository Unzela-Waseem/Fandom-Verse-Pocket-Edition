import 'package:flutter/material.dart';
import '../../../core/media/remote_media.dart';
import '../../authentication/presentation/landing_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Map<String, String>> _slides = [
    {
      'title': 'Anime & Manga Multiverse',
      'subtitle': 'Discover legendary Shinobi sagas, character profiles, sakuga animations, and glossary terms.',
      'image': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=1000&q=80',
      'tag': '🐉 ANIME & MANGA HUB',
      'badgeColor': '0xFFFF9800',
    },
    {
      'title': 'Gaming & Esports Arenas',
      'subtitle': 'Explore community speedrunning routes, competitive brackets, DLC guides, and retro gaming lore.',
      'image': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1000&q=80',
      'tag': '🎮 ESPORTS & GAMING',
      'badgeColor': '0xFFAB47BC',
    },
    {
      'title': 'GPS Maps & AI Fan Helper',
      'subtitle': 'Locate nearby fan meetups, navigate venue coordinates on Google Maps, and chat with our AI Fan Helper.',
      'image': 'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?w=1000&q=80',
      'tag': '📍 EVENTS & AI ASSISTANT',
      'badgeColor': '0xFF29B6F6',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0612),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background PageView with Character Images
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  RemoteMediaImage(url: slide['image']!, fit: BoxFit.cover),
                  // Dark Vignette & Gradient Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x88000000),
                          Color(0xCC0A0612),
                          Color(0xFF0A0612),
                        ],
                        stops: [0.0, 0.55, 0.9],
                      ),
                    ),
                  ),

                  // Slide Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          const Spacer(),
                          // Category Tag Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(int.parse(slide['badgeColor']!)).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Color(int.parse(slide['badgeColor']!)),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              slide['tag']!,
                              style: TextStyle(
                                color: Color(int.parse(slide['badgeColor']!)),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide['subtitle']!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 120), // Leave space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _onFinish,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1E1438),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('SKIP TOUR', style: TextStyle(color: Color(0xFFC77DFF), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),

          // Bottom Controls (Page Indicators & Next/Get Started Button)
          Positioned(
            left: 24,
            right: 24,
            bottom: 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (idx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentPage == idx ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == idx
                            ? const Color(0xFFA855F7)
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),

                // Next or Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _onFinish();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _slides.length - 1 ? 'GET STARTED' : 'NEXT',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
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
