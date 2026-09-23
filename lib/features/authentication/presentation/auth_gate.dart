import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/presentation/admin_dashboard.dart';
import '../../dashboard/presentation/fan_shell.dart';
import '../application/auth_providers.dart';
import '../domain/app_user.dart';
import 'landing_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authStateProvider)
        .when(
          loading: () => const _LoadingScreen(),
          error: (_, _) => const _RecoveryScreen(
            message:
                'Unable to verify your session. Check your connection and try again.',
          ),
          data: (firebaseUser) {
            if (firebaseUser == null) return const LandingScreen();
            return ref
                .watch(currentUserProfileProvider(firebaseUser.uid))
                .when(
                  loading: () => const _LoadingScreen(),
                  error: (error, _) => _RecoveryScreen(
                    message: error is FormatException
                        ? error.message
                        : 'Your profile could not be loaded. No privileged access was granted.',
                    onSignOut: () => ref.read(authServiceProvider).signOut(),
                  ),
                  data: (profile) => switch (profile.role) {
                    UserRole.fan => FanShell(profile: profile),
                    UserRole.admin => AdminDashboard(profile: profile),
                  },
                );
          },
        );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _RecoveryScreen extends StatelessWidget {
  const _RecoveryScreen({required this.message, this.onSignOut});

  final String message;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 64),
                const SizedBox(height: 20),
                Text(message, textAlign: TextAlign.center),
                if (onSignOut != null) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onSignOut,
                    child: const Text('Return to sign in'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
