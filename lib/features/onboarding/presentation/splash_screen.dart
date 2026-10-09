import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/widgets/premium_layout.dart';
import '../../authentication/presentation/auth_gate.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late final VideoPlayerController _controller;
  Timer? _fallback;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash_video.mp4');
    _controller.addListener(_onVideoChanged);
    _fallback = Timer(const Duration(seconds: 12), _navigate);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      // Muting before initialization/play also permits browser autoplay.
      await _controller.setVolume(0);
      await _controller.initialize();
      if (!mounted || _navigating) return;
      await _controller.setVolume(0);
      if (!mounted || _navigating) return;
      setState(() {});
      await _controller.play();
      if (!mounted || _navigating) return;
      _fallback?.cancel();
      _fallback = Timer(
          _controller.value.duration + const Duration(seconds: 3), _navigate);
    } catch (_) {
      // Keep the branded fallback and Skip button usable without video.
      if (mounted && !_navigating) {
        _fallback?.cancel();
        _fallback = Timer(const Duration(seconds: 3), _navigate);
      }
    }
  }

  void _onVideoChanged() {
    final video = _controller.value;
    if (video.isInitialized &&
        video.duration > Duration.zero &&
        video.position >= video.duration) {
      _navigate();
    }
  }

  void _navigate() {
    if (!mounted || _navigating) return;
    _navigating = true;
    _fallback?.cancel();
    _controller.removeListener(_onVideoChanged);
    unawaited(_controller.pause());
    Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AuthGate()));
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _controller.removeListener(_onVideoChanged);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF08061A),
        body: Stack(fit: StackFit.expand, children: [
          if (_controller.value.isInitialized)
            ClipRect(
                child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    )))
          else
            Image.asset('assets/premium_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF211039))),
          const DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x5506040F), Color(0x1106040F), Color(0xD906040F)],
          ))),
          SafeArea(
              child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(children: [
                                    const Expanded(
                                        child: Text('FANDOM VERSE',
                                            style: TextStyle(
                                                letterSpacing: 2,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white))),
                                    GlassPanel(
                                        radius: 30,
                                        padding: EdgeInsets.zero,
                                        child: TextButton.icon(
                                          onPressed: _navigate,
                                          icon: const Icon(Icons.arrow_forward,
                                              size: 16, color: Colors.white),
                                          label: const Text('Skip',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        )),
                                  ]),
                                  const SizedBox(height: 40),
                                  Center(
                                      child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 24, right: 24, top: 24, bottom: 0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Icon(Icons.auto_awesome,
                                              color: Color(0xFFD8B4FE),
                                              size: 28),
                                          SizedBox(height: 16),
                                          Text('A universe of\npossibilities.',
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -.8,
                                                  height: 1.1,
                                                  color: Colors.white)),
                                          SizedBox(height: 14),
                                          Text(
                                              'Your fandom. Your people. Your place.',
                                              style: TextStyle(
                                                  color: Color(0xFFE9D5FF),
                                                  height: 1.5)),
                                          SizedBox(height: 20),
                                          Row(children: [
                                            Icon(Icons.volume_off_outlined,
                                                size: 16,
                                                color: Colors.white60),
                                            SizedBox(width: 8),
                                            Expanded(
                                                child: Text(
                                                    'SOUND OFF · IMAGINATION ON',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        letterSpacing: 1.4,
                                                        color: Colors.white60)))
                                          ]),
                                        ])),
                                  )),
                                ]),
                          ),
                        ),
                      ))),
        ]),
      );
}
