import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreview extends StatefulWidget {
  final File file;
  const MediaPreview({super.key, required this.file});

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _controller;
  bool isVideo = false;

  @override
  void initState() {
    super.initState();
   
    String path = widget.file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi')) {
      isVideo = true;
      _controller = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.play();
          _controller?.setVolume(0); 
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return _controller != null && _controller!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      return Image.file(widget.file, fit: BoxFit.cover);
    }
  }
}