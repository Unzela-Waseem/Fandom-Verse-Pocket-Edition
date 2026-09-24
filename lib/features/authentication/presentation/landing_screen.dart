import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../dashboard/presentation/fan_shell.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.multiverse, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xFF101014)],
                stops: [0.25, 0.78],
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.bolt, color: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'FANDOM VERSE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Your worlds.\nOne universe.',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: .98,
                              letterSpacing: -1.4,
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
                      TextButton.icon(
                        onPressed: () => _openLogin(context, admin: true),
                        icon: const Icon(Icons.shield_outlined, size: 18),
                        label: const Text('Admin sign in'),
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
