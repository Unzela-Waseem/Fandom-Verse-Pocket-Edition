import 'package:fandom_verse_pocket/app/theme/app_theme.dart';
import 'package:fandom_verse_pocket/core/widgets/premium_layout.dart';
import 'package:fandom_verse_pocket/features/admin/presentation/admin_dashboard.dart';
import 'package:fandom_verse_pocket/features/authentication/domain/app_user.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/login_screen.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/registration_screen.dart';
import 'package:fandom_verse_pocket/features/ai_helper/presentation/ai_helper_screen.dart';
import 'package:fandom_verse_pocket/features/contact/presentation/contact_screen.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/complete_fan_profile_screen.dart';
import 'package:fandom_verse_pocket/features/events/presentation/events_screen.dart';
import 'package:fandom_verse_pocket/features/discussions/presentation/discussions_screen.dart';
import 'package:fandom_verse_pocket/features/notifications/presentation/notifications_screen.dart';
import 'package:fandom_verse_pocket/features/profile/presentation/edit_profile_screen.dart';
import 'package:fandom_verse_pocket/features/profile/presentation/profile_screen.dart';
import 'package:fandom_verse_pocket/features/library/data/demo_catalog.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';
import 'package:fandom_verse_pocket/features/merchandise/presentation/ar_preview_screen.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/fan_shell.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/about_us_screen.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/contact_us_screen.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/privacy_policy_screen.dart';
import 'package:fandom_verse_pocket/features/library/presentation/beginner_hub_screen.dart';
import 'package:fandom_verse_pocket/features/library/presentation/deep_dive_screen.dart';
import 'package:fandom_verse_pocket/features/library/presentation/explore_screen.dart';
import 'package:fandom_verse_pocket/features/merchandise/presentation/store_screen.dart';
import 'package:fandom_verse_pocket/features/merchandise/presentation/wishlist_screen.dart';
import 'package:fandom_verse_pocket/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _admin = AppUser(
    uid: 'preview',
    displayName: 'Alex Morgan',
    email: 'preview@example.com',
    role: UserRole.admin,
    selectedFandoms: [],
    badge: 'Admin');

Future<void> _pumpFrames(WidgetTester tester) async {
  // Carousels and loading indicators may intentionally keep animating.
  for (var frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final pages = <String, Widget>{
    'onboarding': const OnboardingScreen(),
    'admin': const AdminDashboard(profile: _admin),
    'fan shell': const FanShell(),
    'explore': const ExploreScreen(),
    'beginner hub': const BeginnerHubScreen(),
    'deep dive': const DeepDiveScreen(),
    'store': const AppScaffold(body: StoreScreen()),
    'cart': const CartScreen(),
    'wishlist': const WishlistScreen(),
    'login': const LoginScreen(adminMode: false),
    'registration': const RegistrationScreen(),
    'AI helper': const AiHelperScreen(),
    'contact form': const ContactScreen(),
    'about': const AboutUsScreen(),
    'contact': const ContactUsScreen(),
    'privacy': const PrivacyPolicyScreen(),
    'profile': const AppScaffold(body: ProfileScreen()),
    'edit profile': const EditProfileScreen(profile: AppUser(uid: 'fan-preview', displayName: 'Alex Morgan', email: 'preview@example.com', role: UserRole.fan, selectedFandoms: ['Anime'], badge: 'New Explorer')),
    'complete profile': const CompleteFanProfileScreen(profile: _admin),
    'events': const AppScaffold(body: EventsScreen()),
    'event details': EventDetailScreen(event: eventCatalog.first),
    'content details': ContentDetailScreen(item: contentCatalog.firstWhere((item) => item.type == ContentType.story)),
    'notifications': const NotificationsScreen(),
    'discussions': const DiscussionsScreen(),
    'AR preview': ARPreviewScreen(productName: productCatalog.first.name, product: productCatalog.first, catalog: productCatalog),
  };
  for (final viewport in [
    (size: const Size(320, 740), scale: 1.0),
    (size: const Size(844, 390), scale: 1.0),
    (size: const Size(768, 1024), scale: 1.0),
    (size: const Size(1440, 1000), scale: 1.0),
    (size: const Size(390, 844), scale: 1.5),
  ]) {
    for (final page in pages.entries) {
      testWidgets(
          '${page.key} fits ${viewport.size} at ${viewport.scale}x text',
          (tester) async {
        tester.view.physicalSize = viewport.size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = viewport.scale;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        await tester.pumpWidget(ProviderScope(
            child: MaterialApp(theme: AppTheme.dark, home: page.value)));
        await _pumpFrames(tester);
        expect(tester.takeException(), isNull);
        final scrollable = find.byType(Scrollable).hitTestable();
        if (scrollable.evaluate().isNotEmpty && page.key != 'onboarding') {
          for (var i = 0; i < 4; i++) {
            await tester.drag(scrollable.first, const Offset(0, -500));
            await _pumpFrames(tester);
            expect(tester.takeException(), isNull);
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await _pumpFrames(tester);
      }, variant: TargetPlatformVariant.only(page.key == 'AR preview' ? TargetPlatform.linux : TargetPlatform.android));
    }
  }

  testWidgets('onboarding controls reach both existing sign-in routes',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        child:
            MaterialApp(theme: AppTheme.dark, home: const OnboardingScreen())));
    await _pumpFrames(tester);
    await tester.tap(find.text('Skip'));
    await _pumpFrames(tester);
    await tester.ensureVisible(find.text('Admin sign in'));
    await tester.tap(find.text('Admin sign in'));
    await _pumpFrames(tester);
    expect(
        tester.widget<LoginScreen>(find.byType(LoginScreen)).adminMode, isTrue);
    Navigator.of(tester.element(find.byType(LoginScreen))).pop();
    await _pumpFrames(tester);
    await tester.ensureVisible(find.text('Continue as a fan'));
    await tester.tap(find.text('Continue as a fan'));
    await _pumpFrames(tester);
    expect(tester.widget<LoginScreen>(find.byType(LoginScreen)).adminMode,
        isFalse);
  });
}
