import 'package:fandom_verse_pocket/app/app.dart';
import 'package:fandom_verse_pocket/features/authentication/presentation/landing_screen.dart';
import 'package:fandom_verse_pocket/features/library/data/demo_catalog.dart';
import 'package:fandom_verse_pocket/features/library/presentation/explore_screen.dart';
import 'package:flutter/material.dart';
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

  testWidgets('Beginner Hub opens its Explore results and story', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: FandomVerseApp(home: LandingScreen())),
    );
    await tester.tap(find.text('EXPLORE PREVIEW'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner Hub'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your first journey through the multiverse'),
      findsOneWidget,
    );

    await tester.tap(find.text('Your first journey through the multiverse'));
    await tester.pumpAndSettle();
    expect(find.byType(ContentDetailScreen), findsOneWidget);
    expect(find.text('By Fandom Verse Editorial'), findsOneWidget);
  });

  for (final category in {for (final item in contentCatalog) item.category}) {
    testWidgets('$category shows its story without a Material error', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(initialCategory: category, standalone: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final item = contentCatalog.firstWhere(
        (item) => item.category == category,
      );
      expect(find.text(item.title), findsOneWidget);
      await tester.tap(find.text(item.title));
      await tester.pumpAndSettle();
      expect(find.byType(ContentDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
