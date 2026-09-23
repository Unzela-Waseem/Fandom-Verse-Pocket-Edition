import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Every fandom.\nOne universe.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Discover stories, events, communities, and collectibles built around what you love.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openLogin(context, admin: false),
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Continue as a fan'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _openLogin(context, admin: true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Admin sign in'),
              ),
              const SizedBox(height: 12),
              Text(
                'Admin accounts are provisioned securely. Public admin registration is disabled.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
