import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_screen.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
        _controller.play();
        _controller.setVolume(1.0); // Play with sound if there is any
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        _controller.value.duration == _controller.value.position) {
      // Video has finished playing
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (_isNavigating) return;
    _isNavigating = true;
    _controller.removeListener(_videoListener);
    _controller.pause();
    
    // Navigate to Onboarding, replacing the splash screen entirely
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player (Centered & Scaled)
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE879F9),
              ),
            ),
            
          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: SafeArea(
              child: TextButton(
                onPressed: _navigateToNext,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Skip'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
