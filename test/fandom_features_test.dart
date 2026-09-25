import 'package:fandom_verse_pocket/features/authentication/domain/app_user.dart';
import 'package:fandom_verse_pocket/features/dashboard/presentation/fan_shell.dart';
import 'package:fandom_verse_pocket/features/library/presentation/beginner_hub_screen.dart';
import 'package:fandom_verse_pocket/features/library/presentation/deep_dive_screen.dart';
import 'package:fandom_verse_pocket/features/library/presentation/explore_screen.dart';
import 'package:fandom_verse_pocket/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Fandom SRS & Hubs Test Suite', () {
    testWidgets('1️⃣ Beginner Hub opens, selects fandom, and displays glossary terms', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: BeginnerHubScreen(initialFandom: 'Anime')),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Beginner Fan Hub 🌱'), findsOneWidget);
      expect(find.textContaining('Glossary'), findsOneWidget);
      expect(find.textContaining('Profiles'), findsOneWidget);
      expect(find.textContaining('Stories'), findsOneWidget);

      // Verify Anime terms from SRS are displayed
      expect(find.text('Anime'), findsAtLeastNWidgets(1));
      expect(find.text('Manga'), findsOneWidget);
      expect(find.text('OVA'), findsOneWidget);
      expect(find.text('Cosplay'), findsOneWidget);
      expect(find.text('Shonen'), findsOneWidget);

      // Tap on 'Manga' term to open explanation modal
      await tester.tap(find.text('Manga'));
      await tester.pumpAndSettle();
      expect(find.text('Definition'), findsOneWidget);
      expect(find.text('Got it!'), findsOneWidget);
      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      // Switch fandom to Gaming
      await tester.tap(find.text('Gaming'));
      await tester.pumpAndSettle();
      expect(find.text('DLC'), findsOneWidget);
      expect(find.text('Mod'), findsOneWidget);
      expect(find.text('Speedrun'), findsOneWidget);
      expect(find.text('Easter Egg'), findsOneWidget);
    });

    testWidgets('2️⃣ Deep Dive opens with Hidden Trivia, Lore, and Behind-the-Scenes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DeepDiveScreen(initialFandom: 'All')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deep Dive 🧠'), findsOneWidget);
      expect(find.textContaining('Hidden Trivia'), findsOneWidget);
      expect(find.textContaining('Advanced Lore'), findsOneWidget);
      expect(find.textContaining('Behind-the-Scenes'), findsOneWidget);

      // Test reveal trivia button
      final revealBtn = find.text('Tap to Reveal Trivia Fact').first;
      await tester.tap(revealBtn);
      await tester.pumpAndSettle();
      expect(find.text('SECRET REVEALED'), findsOneWidget);

      // Switch to Advanced Lore tab
      await tester.tap(find.textContaining('Advanced Lore'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chakra Cycle'), findsOneWidget);

      // Switch to Behind-the-Scenes tab
      await tester.tap(find.textContaining('Behind-the-Scenes'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sakuga'), findsOneWidget);
    });

    testWidgets('3️⃣ Explore Screen supports Multimedia Hub filter, Creator filter & Tags', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ExploreScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Resources & Media filter chips exist
      expect(find.text('RESOURCES & MEDIA'), findsOneWidget);
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Galleries'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Podcasts'), findsOneWidget);

      // Verify Trending Tags exist
      expect(find.text('TRENDING TAGS'), findsOneWidget);
      expect(find.text('#anime'), findsOneWidget);
      expect(find.text('#marvel'), findsOneWidget);
      expect(find.text('#gaming'), findsOneWidget);

      // Filter by News
      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Season Announced'), findsAtLeastNWidgets(1));

      // Filter by Videos
      await tester.tap(find.text('Videos'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Video:'), findsAtLeastNWidgets(1));

      // Filter by Podcasts
      await tester.tap(find.text('Podcasts'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Podcast:'), findsAtLeastNWidgets(1));
    });

    testWidgets('4️⃣ Search handles case-insensitivity and empty/negative queries', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ExploreScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Test lower case 'anime'
      await tester.enterText(searchField, 'anime');
      await tester.pumpAndSettle();
      expect(find.textContaining('Anime'), findsAtLeastNWidgets(1));

      // Test upper case 'ANIME'
      await tester.enterText(searchField, 'ANIME');
      await tester.pumpAndSettle();
      expect(find.textContaining('Anime'), findsAtLeastNWidgets(1));

      // Test title case 'Anime'
      await tester.enterText(searchField, 'Anime');
      await tester.pumpAndSettle();
      expect(find.textContaining('Anime'), findsAtLeastNWidgets(1));

      // Test keyword 'Naruto'
      await tester.enterText(searchField, 'Naruto');
      await tester.pumpAndSettle();
      expect(find.textContaining('Naruto: Whispers'), findsOneWidget);

      // Test keyword 'Marvel'
      await tester.enterText(searchField, 'Marvel');
      await tester.pumpAndSettle();
      expect(find.textContaining('Marvel Multiverse'), findsOneWidget);

      // Test negative query 'xyzabc123'
      await tester.enterText(searchField, 'xyzabc123');
      await tester.pumpAndSettle();
      expect(find.text('No content matches these filters.'), findsOneWidget);
      expect(find.text('Reset all filters'), findsOneWidget);

      // Reset filters restores content
      await tester.tap(find.text('Reset all filters'));
      await tester.pumpAndSettle();
      expect(find.text('No content matches these filters.'), findsNothing);
    });

    testWidgets('5️⃣ Home Screen renders Trending Carousel, Hub shortcuts, and Personalization', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testProfile = AppUser(
        uid: 'test-fan-1',
        email: 'fan@example.com',
        displayName: 'Anime Champion',
        role: UserRole.fan,
        selectedFandoms: const ['Anime', 'Gaming'],
        badge: 'Lore Keeper',
        bio: 'I love anime sagas and competitive arena games!',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FanShell(profile: testProfile),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and greeting
      expect(find.text('Anime Champion'), findsOneWidget);

      // Check Trending Fandom Carousel
      expect(find.text('Trending Fandoms Carousel'), findsOneWidget);
      expect(find.text('#1 TRENDING UNIVERSE'), findsOneWidget);
      expect(find.text('Shinobi Rising & New Seasons'), findsOneWidget);

      // Check Hub Shortcuts
      expect(find.text('Beginner Hub 🌱'), findsOneWidget);
      expect(find.text('Deep Dive 🧠'), findsOneWidget);

      // Check Personalized section based on user's selected fandoms
      expect(find.text('Curated for you'), findsOneWidget);
    });

    testWidgets('6️⃣ Profile displays Bio, Avatar, Liked Fandoms, Bookmarks, and Orders', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testProfile = AppUser(
        uid: 'fan-test-id',
        email: 'fan@test.com',
        displayName: 'Multiverse Rider',
        role: UserRole.fan,
        selectedFandoms: const ['Anime', 'Comics'],
        badge: 'Cosplayer',
        bio: 'Crafting armor and studying the infinite multiverse!',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(profile: testProfile),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Display Name & Badge
      expect(find.text('Multiverse Rider'), findsOneWidget);
      expect(find.text('Cosplayer'), findsOneWidget);

      // Check Bio
      expect(
        find.text('Crafting armor and studying the infinite multiverse!'),
        findsOneWidget,
      );

      // Check Liked Fandoms
      expect(find.text('Anime'), findsOneWidget);
      expect(find.text('Comics'), findsOneWidget);

      // Check Counters
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });
  });
}
