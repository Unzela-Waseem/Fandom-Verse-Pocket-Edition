// Local UI preview only: no Firebase initialization, authentication, or writes.
// flutter run -d web-server -t test/support/design_preview.dart --web-port 7357
// Use ?page=admin, ?page=fan, ?page=login or ?page=splash. Add &width=390
// to review a phone-sized frame on a desktop browser.
import 'package:fandom_verse_pocket/app/theme/app_theme.dart';
import 'package:fandom_verse_pocket/features/admin/presentation/admin_dashboard.dart';
import 'package:fandom_verse_pocket/features/authentication/application/auth_providers.dart';
import 'package:fandom_verse_pocket/features/authentication/domain/app_user.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/login_screen.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/fan_shell.dart';
import 'package:fandom_verse_pocket/features/onboarding/presentation/onboarding_screen.dart';
import 'package:fandom_verse_pocket/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final params = Uri.base.queryParameters;
  final page = switch (params['page']) {
    'admin' => const AdminDashboard(
        profile: AppUser(
            uid: 'preview',
            displayName: 'Alex Morgan',
            email: 'preview@example.com',
            role: UserRole.admin,
            selectedFandoms: [],
            badge: 'Admin')),
    'fan' => const FanShell(),
    'login' => const LoginScreen(adminMode: false),
    'splash' => const VideoSplashScreen(),
    _ => const OnboardingScreen(),
  };
  runApp(ProviderScope(
    overrides: [authStateProvider.overrideWith((ref) => Stream.value(null))],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) =>
          LayoutBuilder(builder: (context, constraints) {
        final width =
            (double.tryParse(params['width'] ?? '') ?? constraints.maxWidth)
                .clamp(280.0, constraints.maxWidth);
        return ColoredBox(
            color: const Color(0xFF06040F),
            child: Center(
                child: SizedBox(
              width: width,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(size: Size(width, constraints.maxHeight)),
                  child: child!),
            )));
      }),
      home: page,
    ),
  ));
}
