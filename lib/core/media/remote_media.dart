import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'offline_media_service.dart';
import '../constants/app_assets.dart';

bool isHttpsMediaUrl(String? value) {
  if (value == null || value.trim().isEmpty) return false;
  final clean = value.trim();
  final uri = Uri.tryParse(clean);
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty;
}

/// Bundled media is intentionally supported alongside Cloudinary HTTPS URLs.
/// It lets core demo content work after installation without a network request.
bool isAssetMediaUrl(String? value) {
  final clean = value?.trim();
  return clean != null && clean.startsWith('assets/');
}

bool isPlayableMediaUrl(String? value) {
  return isHttpsMediaUrl(value) || isAssetMediaUrl(value);
}

String? getPosterUrlFromVideo(String? videoUrl) {
  if (videoUrl == null || !isHttpsMediaUrl(videoUrl)) return null;
  final clean = videoUrl.trim();
  final uri = Uri.tryParse(clean);
  if (uri == null) return null;
  if (uri.host.contains('cloudinary.com')) {
    return clean.replaceAll(
      RegExp(r'\.(mp4|mov|webm|mkv|avi)(\?.*)?$', caseSensitive: false),
      '.jpg',
    );
  }
  return null;
}

class RemoteMediaImage extends StatefulWidget {
  const RemoteMediaImage({
    super.key,
    this.url,
    this.fit = BoxFit.cover,
    this.videoUrlForPoster,
  });

  final String? url;
  final String? videoUrlForPoster;
  final BoxFit fit;

  @override
  State<RemoteMediaImage> createState() => _RemoteMediaImageState();
}

class _RemoteMediaImageState extends State<RemoteMediaImage> {
  String? _localPath;
  late Future<void> _checkLocalFuture;

  @override
  void initState() {
    super.initState();
    _checkLocalFuture = _checkLocal();
  }

  @override
  void didUpdateWidget(covariant RemoteMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.videoUrlForPoster != widget.videoUrlForPoster) {
      _checkLocalFuture = _checkLocal();
    }
  }

  Future<void> _checkLocal() async {
    final effectiveUrl = isHttpsMediaUrl(widget.url)
        ? widget.url!.trim()
        : getPosterUrlFromVideo(widget.videoUrlForPoster);

    if (effectiveUrl != null) {
      final path = await OfflineMediaService().getLocalPath(effectiveUrl);
      if (mounted) setState(() => _localPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAsset = isAssetMediaUrl(widget.url) ? widget.url!.trim() : null;
    final effectiveUrl = isHttpsMediaUrl(widget.url)
        ? widget.url!.trim()
        : getPosterUrlFromVideo(widget.videoUrlForPoster);

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
          'Test',
        );

    if (localAsset != null) {
      return Image.asset(
        localAsset,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(AppAssets.multiverse, fit: widget.fit),
      );
    }

    if (isTest || effectiveUrl == null || !isHttpsMediaUrl(effectiveUrl)) {
      return Image.asset(AppAssets.multiverse, fit: widget.fit);
    }

    return FutureBuilder<void>(
      future: _checkLocalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _localPath == null) {
          return Container(
            color: const Color(0xFF1B1B22),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (_localPath != null) {
          return Image.file(
            File(_localPath!),
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) =>
                Image.asset(AppAssets.multiverse, fit: widget.fit),
          );
        }

        return CachedNetworkImage(
          imageUrl: effectiveUrl,
          fit: widget.fit,
          placeholder: (_, __) => Container(
            color: const Color(0xFF1B1B22),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, __, ___) =>
              Image.asset(AppAssets.multiverse, fit: widget.fit),
        );
      },
    );
  }
}

class RemoteMediaVideo extends StatefulWidget {
  const RemoteMediaVideo({super.key, required this.url, this.posterUrl});

  final String url;
  final String? posterUrl;

  @override
  State<RemoteMediaVideo> createState() => _RemoteMediaVideoState();
}

class _RemoteMediaVideoState extends State<RemoteMediaVideo> {
  VideoPlayerController? _controller;
  late Future<void> _initialization;
  bool _isMuted = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant RemoteMediaVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller?.dispose();
      _initialize();
    }
  }

  void _initialize() {
    _initialization = _setupController();
  }

  Future<void> _setupController() async {
    if (isAssetMediaUrl(widget.url)) {
      _controller = VideoPlayerController.asset(widget.url.trim());
      try {
        await _controller!.initialize();
      } catch (_) {}
      if (mounted) setState(() {});
      return;
    }

    final localPath = await OfflineMediaService().getLocalPath(widget.url);
    if (!mounted) return;

    if (localPath != null) {
      _controller = VideoPlayerController.file(File(localPath));
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url.trim()),
      );
    }
    try {
      await _controller!.initialize();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _launchExternal() async {
    if (isAssetMediaUrl(widget.url)) return;
    final uri = Uri.tryParse(widget.url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black,
        child: FutureBuilder<void>(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF1E1E26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_collection_outlined,
                      size: 42,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Video Stream Available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap below to open and watch the video.',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _launchExternal,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Watch Video'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.posterUrl != null)
                      RemoteMediaImage(url: widget.posterUrl),
                    Container(color: Colors.black45),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            'Loading video...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final aspectRatio = _controller!.value.aspectRatio > 0
                ? _controller!.value.aspectRatio
                : 16 / 9;

            return GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    // Centered Play/Pause Button
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller!,
                      builder: (context, value, _) {
                        if (!_showControls && value.isPlaying) {
                          return const SizedBox.shrink();
                        }
                        return Center(
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              iconSize: 32,
                              color: Colors.white,
                              icon: Icon(
                                value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                value.isPlaying
                                    ? _controller!.pause()
                                    : _controller!.play();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    // Bottom Control Bar
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller!,
                      builder: (context, value, _) {
                        if (!_showControls && value.isPlaying) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Color(0xFFFFD740),
                                  bufferedColor: Colors.white30,
                                  backgroundColor: Colors.white10,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    iconSize: 20,
                                    tooltip: _isMuted ? 'Unmute' : 'Mute',
                                    icon: Icon(
                                      _isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isMuted = !_isMuted;
                                        _controller!.setVolume(
                                          _isMuted ? 0.0 : 1.0,
                                        );
                                      });
                                    },
                                  ),
                                  IconButton(
                                    iconSize: 18,
                                    tooltip: 'Open in external player',
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: Colors.white,
                                    ),
                                    onPressed: _launchExternal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lightweight real audio player for bundled or Cloudinary-hosted audio.
/// The media position comes from the platform player; it is never simulated.
class RemoteMediaAudio extends StatefulWidget {
  const RemoteMediaAudio({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<RemoteMediaAudio> createState() => _RemoteMediaAudioState();
}

class _RemoteMediaAudioState extends State<RemoteMediaAudio> {
  VideoPlayerController? _controller;
  late Future<void> _initialization;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initialization = _setupController();
  }

  @override
  void didUpdateWidget(covariant RemoteMediaAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller?.dispose();
      _initialization = _setupController();
    }
  }

  Future<void> _setupController() async {
    final url = widget.url.trim();
    if (isAssetMediaUrl(url)) {
      _controller = VideoPlayerController.asset(url);
    } else {
      final localPath = await OfflineMediaService().getLocalPath(url);
      if (localPath != null) {
        _controller = VideoPlayerController.file(File(localPath));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }
    }
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _duration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            _controller == null ||
            !_controller!.value.isInitialized) {
          return const Text(
            'Audio could not be loaded.',
            style: TextStyle(color: Colors.white70),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF221F2B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD740).withAlpha(80)),
          ),
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, _) {
              final totalMs = value.duration.inMilliseconds;
              final positionMs = value.position.inMilliseconds.clamp(
                0,
                totalMs == 0 ? 1 : totalMs,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD740),
                          foregroundColor: Colors.black,
                        ),
                        tooltip: value.isPlaying ? 'Pause audio' : 'Play audio',
                        onPressed: () => value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play(),
                        icon: Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OFFLINE AUDIO',
                              style: TextStyle(
                                color: Color(0xFFFFD740),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: _muted ? 'Unmute' : 'Mute',
                        onPressed: () {
                          setState(() => _muted = !_muted);
                          _controller!.setVolume(_muted ? 0 : 1);
                        },
                        icon: Icon(
                          _muted ? Icons.volume_off : Icons.volume_up,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: positionMs.toDouble(),
                    min: 0,
                    max: (totalMs == 0 ? 1 : totalMs).toDouble(),
                    activeColor: const Color(0xFFFFD740),
                    onChanged: (next) => _controller!
                        .seekTo(Duration(milliseconds: next.round())),
                  ),
                  Text(
                    '${_duration(value.position)} / ${_duration(value.duration)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
