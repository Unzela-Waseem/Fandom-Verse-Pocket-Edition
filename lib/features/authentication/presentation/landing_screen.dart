import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../dashboard/presentation/fan_shell.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _openLogin(BuildContext context, {required bool admin}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LoginScreen(adminMode: admin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.multiverse, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x3309040E), Color(0xFF09040E)],
                stops: [0.20, 0.75],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bolt, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'FANDOM VERSE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: .98,
                                letterSpacing: -1.4,
                                color: Colors.white,
                              ),
                          children: const [
                            TextSpan(text: 'Your worlds.\n'),
                            TextSpan(
                              text: 'One universe.',
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
                      const SizedBox(height: 14),
                      Text(
                        'Stories, events, communities, and collectibles for every kind of fan.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => _openLogin(context, admin: false),
                        child: const Text('CONTINUE AS A FAN'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const FanShell(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('EXPLORE PREVIEW'),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 16, color: Color(0xFFE879F9)),
                        label: const Text(
                          'Start Onboarding Tour 🚀',
                          style: TextStyle(color: Color(0xFFE879F9), fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openLogin(context, admin: true),
                        icon: const Icon(Icons.shield_outlined, size: 18, color: Colors.white70),
                        label: const Text('Admin sign in', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
