import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:instagram_clone/core/profile_cus.dart';
import 'package:instagram_clone/views/comments/comments_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/reels/widgets/reel_share_modal.dart';

class ReelItem extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final PageController pageController;
  const ReelItem({super.key, required this.doc, required this.pageController});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _controller;
  bool isLiked = false;
  int likeCount = 0;
  bool _isPlaying = false;
  String _authorPicUrl = '';
  String _authorName = '';
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    var data = widget.doc.data() as Map<String, dynamic>;
    String videoUrl = (data['mediaUrls'] as List<dynamic>).first;

    _checkLikes();
    _fetchUserData();
    _fetchCommentCount();

    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller?.setLooping(true);
      });

    _controller?.addListener(() {
      if (mounted && _controller!.value.isPlaying) {
        setState(() {});
      }
    });
  }

  void _fetchUserData() async {
    var data = widget.doc.data() as Map<String, dynamic>;
    String uid = data['userId'] ?? '';
    if (uid.isEmpty) return;
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists && mounted) {
        var uData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _authorName = uData['username'] ?? uData['name'] ?? 'User';
          _authorPicUrl = uData['profilePicUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _fetchCommentCount() async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.doc.id)
          .collection('comments')
          .get();
      if (mounted) {
        setState(() {
          _commentCount = snap.docs.length;
        });
      }
    } catch (e) {}
  }

  void _checkLikes() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    var data = widget.doc.data() as Map<String, dynamic>;
    List<dynamic> likes = data['likes'] ?? [];
    isLiked = likes.contains(uid);
    likeCount = likes.length;
  }

  void _toggleLike() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    setState(() {
      if (isLiked) {
        likeCount--;
        isLiked = false;
      } else {
        likeCount++;
        isLiked = true;
      }
    });

    DocumentReference postRef = widget.doc.reference;
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    }
  }

  void _showOptionsModal() {
    bool isMe = (FirebaseAuth.instance.currentUser?.uid ==
        (widget.doc.data() as Map<String, dynamic>)['userId']);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text('post_delete'.tr(),
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.doc.id)
                          .delete();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.white),
                  title: Text('post_report'.tr(),
                      style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.doc.id),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction > 0.8) {
          _controller?.play();
          setState(() => _isPlaying = true);
        } else {
          _controller?.pause();
          setState(() => _isPlaying = false);
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoBackground(),
            _buildGradients(),
            SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildTopInfoOverlay(),
                  _buildBottomActionOverlay(),
                ],
              ),
            ),
            if (!_isPlaying &&
                _controller != null &&
                _controller!.value.isInitialized)
              const Center(
                  child: IgnorePointer(
                      child: Icon(Icons.play_arrow,
                          color: Colors.white54, size: 80))),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    return GestureDetector(
      onTap: () {
        if (_controller != null) {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
            setState(() => _isPlaying = false);
          } else {
            _controller!.play();
            setState(() => _isPlaying = true);
          }
        }
      },
      child: _controller != null && _controller!.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildGradients() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: IgnorePointer(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 220,
          child: IgnorePointer(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfoOverlay() {
    var data = widget.doc.data() as Map<String, dynamic>;
    String username =
        _authorName.isNotEmpty ? _authorName : (data['username'] ?? 'User');
    String desc = data['description'] ?? '';

    Timestamp? ts = data['timestamp'] as Timestamp?;
    String dateStr = '';
    if (ts != null) {
      DateTime dt = ts.toDate();
      List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${months[dt.month - 1]} ${dt.day}';
    }

    return Positioned(
        top: 15,
        left: 15,
        right: 15,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desc.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                            child: Text(desc,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  if (desc.isNotEmpty) const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  body: ProfileCus(
                                      uid: data['userId'],
                                      username: username))));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: _authorPicUrl.isNotEmpty
                              ? NetworkImage(_authorPicUrl)
                              : const AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(username,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(' · ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                                Text('profile_follow'.tr(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                            if (dateStr.isNotEmpty)
                              Text(dateStr,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: const Icon(Icons.close, color: Colors.white, size: 28)),
          ],
        ));
  }

  Widget _buildBottomActionOverlay() {
    String duration = _controller != null && _controller!.value.isInitialized
        ? '${_controller!.value.position.inMinutes.toString().padLeft(2, '0')}:${(_controller!.value.position.inSeconds % 60).toString().padLeft(2, '0')}'
        : '00:00';

    return Positioned(
      bottom: 10,
      left: 15,
      right: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '$likeCount ${'feed_likes'.tr()}  ·  $_commentCount ${'feed_comments'.tr()}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                  onTap: _toggleLike,
                  child: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white, size: 28)),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CommentsScreen(postId: widget.doc.id)));
                },
                child: Image.asset('assets/images/comment.png',
                    width: 25, color: Colors.white),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                  onTap: () => ReelShareModal.show(context, widget.doc),
                  child: Image.asset('assets/images/send.png',
                      width: 25, color: Colors.white)),
              const SizedBox(width: 20),
              GestureDetector(
                  onTap: _showOptionsModal,
                  child: const Icon(Icons.more_horiz,
                      color: Colors.white, size: 28)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.keyboard_arrow_up,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('create_post_next'.tr(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_controller != null) {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                      setState(() => _isPlaying = false);
                    } else {
                      _controller!.play();
                      setState(() => _isPlaying = true);
                    }
                  }
                },
                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _controller != null && _controller!.value.isInitialized
                    ? VideoProgressIndicator(_controller!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        colors: VideoProgressColors(
                            playedColor: Colors.white,
                            bufferedColor: Colors.white.withOpacity(0.5),
                            backgroundColor: Colors.white.withOpacity(0.2)))
                    : Container(),
              ),
              const SizedBox(width: 10),
              Text(duration,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
}
