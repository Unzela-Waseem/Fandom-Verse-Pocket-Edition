import 'package:fandom_verse_pocket/features/authentication/domain/app_user.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/complete_fan_profile_screen.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('social registration requires a display name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegistrationScreen())),
    );
    final googleButton = find.text('Continue with Google');
    await tester.tap(googleButton);
    await tester.pump();
    expect(find.text('Display name is required.'), findsOneWidget);
  });

  testWidgets('social registration requires a selected fandom', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegistrationScreen())),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Display name'),
      'Fan Tester',
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(find.text('Select at least one fandom.'), findsOneWidget);
  });

  testWidgets('social registration requires terms acceptance', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegistrationScreen())),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Display name'),
      'Fan Tester',
    );
    await tester.tap(find.text('Gaming'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(
      find.text('Accept the Terms and Privacy notice to continue.'),
      findsOneWidget,
    );
  });

  testWidgets('first-time social sign-in requires a complete Fan profile', (
    tester,
  ) async {
    const profile = AppUser(
      uid: 'test-user',
      displayName: 'New Explorer',
      email: 'fan@example.com',
      role: UserRole.fan,
      selectedFandoms: [],
      badge: 'New Explorer',
    );
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CompleteFanProfileScreen(profile: profile)),
      ),
    );
    expect(find.text('Complete your fan profile'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Display name is required.'), findsOneWidget);
  });
}
