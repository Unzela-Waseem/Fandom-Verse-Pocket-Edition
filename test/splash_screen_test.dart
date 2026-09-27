import 'dart:async';

import 'package:fandom_verse_pocket/app/theme/app_theme.dart';
import 'package:fandom_verse_pocket/features/authentication/application/auth_providers.dart';
import 'package:fandom_verse_pocket/features/onboarding/presentation/onboarding_screen.dart';
import 'package:fandom_verse_pocket/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Test the same platform boundary used by video_player without a real decoder.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _VideoPlatform extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>();
  final volumes = <double>[];
  final volumesAtPlayback = <double>[];
  bool fail = false;
  double volume = 1;

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    if (fail) throw StateError('Unavailable video');
    events.add(VideoEvent(
        eventType: VideoEventType.initialized,
        size: const Size(1920, 1080),
        duration: const Duration(seconds: 8)));
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> setVolume(int playerId, double value) async {
    volume = value;
    volumes.add(value);
  }

  @override
  Future<void> play(int playerId) async {
    volumesAtPlayback.add(volume);
  }

  @override
  Future<void> pause(int playerId) async {}
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Future<void> dispose(int playerId) async {}
  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);
}

void main() {
  late _VideoPlatform platform;
  late VideoPlayerPlatform original;
  setUp(() {
    original = VideoPlayerPlatform.instance;
    platform = _VideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });
  tearDown(() {
    VideoPlayerPlatform.instance = original;
    unawaited(platform.events.close());
  });

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authStateProvider.overrideWith((ref) => Stream.value(null))],
      child: MaterialApp(theme: AppTheme.dark, home: const VideoSplashScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('splash never plays audio and Skip reaches onboarding',
      (tester) async {
    await launch(tester);
    expect(platform.volumes, isNotEmpty);
    expect(platform.volumes, everyElement(0.0));
    expect(platform.volumesAtPlayback, isNotEmpty);
    expect(platform.volumesAtPlayback, everyElement(0.0));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed video automatically leaves the splash', (tester) async {
    platform.fail = true;
    await launch(tester);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash disposes safely during initialization', (tester) async {
    await launch(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
  });
}
