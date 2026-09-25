import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../admin/presentation/admin_dashboard.dart';
import '../../dashboard/presentation/fan_shell.dart';
import '../application/auth_providers.dart';
import '../domain/app_user.dart';
import 'complete_fan_profile_screen.dart';
import 'landing_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authStateProvider)
        .when(
          loading: () => const _LoadingScreen(),
          error: (_, __) => const _RecoveryScreen(
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
                  data: (profile) {
                    if (profile.accountStatus != 'active') {
                      return _RecoveryScreen(
                        message:
                            'This account is disabled. Contact project support if you believe this is a mistake.',
                        onSignOut: () =>
                            ref.read(authServiceProvider).signOut(),
                      );
                    }
                    if (profile.role == UserRole.fan &&
                        profile.selectedFandoms.isEmpty) {
                      return CompleteFanProfileScreen(profile: profile);
                    }
                    return switch (profile.role) {
                      UserRole.fan => FanShell(profile: profile),
                      UserRole.admin => _VerifiedAdmin(
                        firebaseUser: firebaseUser,
                        profile: profile,
                      ),
                    };
                  },
                );
          },
        );
  }
}

class _VerifiedAdmin extends StatefulWidget {
  const _VerifiedAdmin({required this.firebaseUser, required this.profile});

  final User firebaseUser;
  final AppUser profile;

  @override
  State<_VerifiedAdmin> createState() => _VerifiedAdminState();
}

class _VerifiedAdminState extends State<_VerifiedAdmin> {
  late Future<IdTokenResult> _claim;

  @override
  void initState() {
    super.initState();
    _claim = widget.firebaseUser.getIdTokenResult();
  }

  @override
  void didUpdateWidget(covariant _VerifiedAdmin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firebaseUser.uid != widget.firebaseUser.uid) {
      _claim = widget.firebaseUser.getIdTokenResult();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<IdTokenResult>(
    future: _claim,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const _RecoveryScreen(
          message: 'Admin access could not be verified. Please sign in again.',
          onSignOut: _signOut,
        );
      }
      if (!snapshot.hasData) return const _LoadingScreen();
      if (snapshot.data!.claims?['admin'] != true) {
        return const _RecoveryScreen(
          message: 'Admin access is not configured for this account.',
          onSignOut: _signOut,
        );
      }
      return AdminDashboard(profile: widget.profile);
    },
  );

  static void _signOut() => FirebaseAuth.instance.signOut();
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
