import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NetworkVideoPlayer extends StatefulWidget {
  final String url;
  const NetworkVideoPlayer({super.key, required this.url});

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isInit = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _controller.initialize().timeout(const Duration(seconds: 4)).then((_) {
        if (mounted) {
          _controller.setLooping(true);
          _controller.play();
          setState(() {
            _isInit = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
        debugPrint("Feed Video Error: $error");
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      String thumbnailUrl = widget.url.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbnailUrl, fit: BoxFit.cover),
          const Center(child: Icon(Icons.error_outline, color: Colors.white, size: 50)),
        ]
      );
    }
    if (!_isInit) {
      String thumbnailUrl = widget.url.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbnailUrl, fit: BoxFit.cover),
          const Center(child: CircularProgressIndicator(color: Colors.white54)),
        ]
      );
    }
    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (info) {
        if (!mounted || !_isInit || _hasError) return;
        if (info.visibleFraction < 0.2) {
          if (_isPlaying) {
            _controller.pause();
            if (mounted) setState(() => _isPlaying = false);
          }
        } else if (info.visibleFraction > 0.5) {
          if (!_isPlaying) {
            _controller.play();
            if (mounted) setState(() => _isPlaying = true);
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
            _isPlaying = !_isPlaying;
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio > 0 ? _controller.value.aspectRatio : 1.0,
                child: VideoPlayer(_controller),
              ),
            ),
            if (!_isPlaying)
              const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60)),
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMuted = !_isMuted;
                    _controller.setVolume(_isMuted ? 0.0 : 1.0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
