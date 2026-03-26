import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/cupits/upload/cubit/upload_cubit.dart';
import 'package:video_player/video_player.dart';

class CreatPost extends StatefulWidget {
  const CreatPost({super.key});

  @override
  State<CreatPost> createState() => _CreatPostState();
}

class _CreatPostState extends State<CreatPost> {
  final List<File> _selectedMedia = [];
  final TextEditingController _captionController = TextEditingController();
  int _currentCarouselIndex = 0;

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultipleMedia();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _onUploadStateChanged(BuildContext context, UploadState state) {
    if (state is UploadSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post Shared!')));
      Navigator.pop(context);
    }
    if (state is UploadError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadCubit, UploadState>(
      listener: _onUploadStateChanged,
      builder: (context, state) {
        bool isLoading = state is UploadLoading;
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(isLoading),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedMedia.isNotEmpty)
                      _buildCarousel()
                    else
                      _buildImagePickerPlaceholder(),
                    const Divider(color: Colors.grey, height: 1),
                    _buildCaptionSection(),
                    const Divider(color: Colors.grey, height: 1),
                  ],
                ),
              ),
              if (isLoading) _buildLoadingOverlay(),
            ],
          ),
          floatingActionButton: _selectedMedia.isNotEmpty ? _buildFloatingAddButton() : null,
        );
      },
    );
  }

  AppBar _buildAppBar(bool isLoading) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
      ),
      backgroundColor: Colors.black,
      title: const Text('New Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(
          onPressed: () {
            if (_selectedMedia.isNotEmpty && !isLoading) {
              context.read<UploadCubit>().createPost(
                    files: _selectedMedia,
                    caption: _captionController.text.trim(),
                  );
            }
          },
          child: Text('create_post_share'.tr(),
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            itemCount: _selectedMedia.length,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              bool isVideo = _selectedMedia[index].path.toLowerCase().endsWith('.mp4') ||
                  _selectedMedia[index].path.toLowerCase().endsWith('.mov');

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (isVideo)
                    VideoPreviewWidget(file: _selectedMedia[index])
                  else
                    Image.file(_selectedMedia[index], fit: BoxFit.cover),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMedia.removeAt(index);
                          if (_currentCarouselIndex >= _selectedMedia.length && _currentCarouselIndex > 0) {
                            _currentCarouselIndex--;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (_selectedMedia.length > 1) _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCarouselIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _selectedMedia.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentCarouselIndex == index ? Colors.blueAccent : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    return InkWell(
      onTap: _pickMedia,
      child: Container(
        height: 350,
        width: double.infinity,
        color: Colors.grey[900],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text('Tap to add photos or videos', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedMedia.isNotEmpty) _buildCaptionThumbnail(),
          Expanded(
            child: TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'create_post_caption'.tr(),
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionThumbnail() {
    bool isVideo = _selectedMedia[0].path.toLowerCase().endsWith('.mp4') ||
        _selectedMedia[0].path.toLowerCase().endsWith('.mov');

    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 10, top: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        image: isVideo
            ? null
            : DecorationImage(
                image: FileImage(_selectedMedia[0]),
                fit: BoxFit.cover,
              ),
      ),
      child: isVideo ? const Icon(Icons.videocam, color: Colors.white, size: 24) : null,
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );
  }

  FloatingActionButton _buildFloatingAddButton() {
    return FloatingActionButton(
      onPressed: _pickMedia,
      backgroundColor: Colors.grey[800],
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class VideoPreviewWidget extends StatefulWidget {
  final File file;
  const VideoPreviewWidget({super.key, required this.file});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  String _errorMsg = "";
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      widget.file,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _controller.initialize().timeout(const Duration(seconds: 4)).then((_) {
        if (mounted) {
          _controller.setLooping(true);
          _controller.play();
          setState(() {
            _initialized = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMsg = error.toString();
          });
        }
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
      return Container(
        color: Colors.black87,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Error: $_errorMsg", style: const TextStyle(color: Colors.red, fontSize: 10), textAlign: TextAlign.center),
        )),
      );
    }
    if (!_initialized) {
      return Container(
        color: Colors.black87,
        child: const Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }
    return GestureDetector(
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
              const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 80),
              ),
          ],
        ));
  }
}
