import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_assets.dart';

bool isHttpsMediaUrl(String? value) {
  if (value == null || value.trim().isEmpty) return false;
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty;
}

class RemoteMediaImage extends StatelessWidget {
  const RemoteMediaImage({super.key, this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (!isHttpsMediaUrl(url)) {
      return Image.asset(AppAssets.multiverse, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: url!.trim(),
      fit: fit,
      placeholder: (_, __) => Image.asset(AppAssets.multiverse, fit: fit),
      errorWidget: (_, __, ___) => Image.asset(AppAssets.multiverse, fit: fit),
    );
  }
}

class RemoteMediaVideo extends StatefulWidget {
  const RemoteMediaVideo({super.key, required this.url});

  final String url;

  @override
  State<RemoteMediaVideo> createState() => _RemoteMediaVideoState();
}

class _RemoteMediaVideoState extends State<RemoteMediaVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant RemoteMediaVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller.dispose();
      _initialize();
    }
  }

  void _initialize() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialization = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const ListTile(
          leading: Icon(Icons.video_file_outlined),
          title: Text('Video unavailable'),
          subtitle: Text('Check your connection or try again later.'),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (context, value, _) => IconButton.filledTonal(
              tooltip: value.isPlaying ? 'Pause video' : 'Play video',
              onPressed: () =>
                  value.isPlaying ? _controller.pause() : _controller.play(),
              icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
        ],
      );
    },
  );
}
