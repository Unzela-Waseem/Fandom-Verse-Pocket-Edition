import 'package:fandom_verse_pocket/app/app.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/landing_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('landing screen exposes fan and admin entry points', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: FandomVerseApp(home: LandingScreen())),
    );
    expect(find.text('CONTINUE AS A FAN'), findsOneWidget);
    expect(find.text('Admin sign in'), findsOneWidget);
  });

  testWidgets('preview opens the fan dashboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FandomVerseApp(home: LandingScreen())),
    );
    await tester.tap(find.text('EXPLORE PREVIEW'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });
}
