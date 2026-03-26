import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:instagram_clone/core/profile_cus.dart';
import 'package:instagram_clone/views/comments/comments_screen.dart';
import 'package:instagram_clone/core/network_video_player.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> snap;
  final String postId;
  const Post({super.key, required this.snap, required this.postId});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  int _currentIndex = 0;
  bool isLiked = false;
  int likeCount = 0;
  bool isSaved = false;
  String _authorName = '';
  String _authorPicUrl = '';
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _checkLikes();
    _fetchUserData();
    _fetchCommentCount();
  }

  void _fetchCommentCount() async {
    try {
      var snap = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').count().get();
      if (mounted) setState(() { _commentCount = snap.count ?? 0; });
    } catch (e) {}
  }

  void _fetchUserData() async {
    String uid = widget.snap['userId'] ?? '';
    if (uid.isEmpty) return;
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _authorName = data['username'] ?? data['name'] ?? 'User';
          _authorPicUrl = data['profilePicUrl'] ?? '';
        });
      }
    } catch (e) {}
  }

  void _checkLikes() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    List<dynamic> likes = widget.snap['likes'] ?? [];
    List<dynamic> savedBy = widget.snap['savedBy'] ?? [];
    isLiked = likes.contains(uid);
    likeCount = likes.length;
    isSaved = savedBy.contains(uid);
  }

  @override
  void didUpdateWidget(Post oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snap['likes'] != widget.snap['likes']) {
      _checkLikes();
    }
  }

  void toggleLike() async {
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

    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    if (isLiked) {
      await postRef.update({'likes': FieldValue.arrayUnion([uid])});
      if (widget.snap['userId'] != null && widget.snap['userId'] != uid) {
        await FirebaseFirestore.instance.collection('users').doc(widget.snap['userId']).collection('notifications').add({
          'type': 'like',
          'userId': uid,
          'postId': widget.postId,
          'postUrl': (widget.snap['mediaUrls'] ?? [''])[0],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      await postRef.update({'likes': FieldValue.arrayRemove([uid])});
    }
  }

  void toggleSave() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    setState(() {
      isSaved = !isSaved;
    });

    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    if (isSaved) {
      await postRef.set({'savedBy': FieldValue.arrayUnion([uid])}, SetOptions(merge: true));
    } else {
      await postRef.set({'savedBy': FieldValue.arrayRemove([uid])}, SetOptions(merge: true));
    }
  }

  void _showOptionsModal() {
    bool isMe = (FirebaseAuth.instance.currentUser?.uid == widget.snap['userId']);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text('post_delete'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.white),
                  title: Text('post_report'.tr(), style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        });
  }

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: Column(
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              Text('post_share_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    var docs = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();
                    if (docs.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: Colors.white)));
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        String uid = docs[index].id;
                        String username = data['username'] ?? data['name'] ?? 'User';
                        String url = data['profilePicUrl'] ?? '';
                        return GestureDetector(
                          onTap: () async {
                            List<String> ids = [currentUid, uid];
                            ids.sort();
                            String chatId = ids.join('_');
                            List<dynamic> mediaUrls = widget.snap['mediaUrls'] ?? [];
                            String postUrl = mediaUrls.isNotEmpty ? mediaUrls.first.toString() : '';
                            if (postUrl.isEmpty) return;
                            
                            await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
                              'senderId': currentUid,
                              'text': postUrl,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent to $username!')));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                CircleAvatar(radius: 30, backgroundImage: url.isNotEmpty ? NetworkImage(url) : const AssetImage('assets/images/avatar.png') as ImageProvider),
                                const SizedBox(height: 8),
                                Text(username.length > 8 ? '${username.substring(0, 8)}...' : username, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: Text('post_copy_link'.tr(), style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: Text('post_share_to'.tr(), style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = isDark ? Colors.black : Colors.white;

    double width = MediaQuery.of(context).size.width;
    List<dynamic> mediaUrls = widget.snap['mediaUrls'] ?? [];
    String caption = widget.snap['caption'] ?? widget.snap['description'] ?? '';
    String displayUsername = _authorName.isNotEmpty ? _authorName : (widget.snap['username'] ?? widget.snap['userId'] ?? 'User');
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(bgColor, displayUsername, textColor),
        SizedBox(height: 10),
        _buildMediaCarousel(width, mediaUrls),
        if (mediaUrls.length > 1) _buildCarouselIndicators(mediaUrls),
        SizedBox(height: 10),
        _buildActionRow(textColor),
        SizedBox(height: 10),
        _buildCaptionSection(textColor, displayUsername, caption),
      ],
    );
  }

  Widget _buildHeader(Color bgColor, String displayUsername, Color textColor) {
    return Container(
      width: double.infinity,
      height: 54,
      color: bgColor,
      child: Center(
        child: ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: ProfileCus(uid: widget.snap['userId'], username: displayUsername),
              )));
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: _authorPicUrl.isNotEmpty 
                  ? NetworkImage(_authorPicUrl) 
                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
            ),
          ),
          title: Text(
            displayUsername,
            style: TextStyle(color: textColor, fontFamily: 'inter', fontSize: 15),
          ),
          trailing: InkWell(
            onTap: _showOptionsModal,
            child: Image.asset('assets/images/more.png', color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCarousel(double width, List<dynamic> mediaUrls) {
    return Container(
      width: width,
      height: width,
      color: Colors.grey[900],
      child: mediaUrls.isEmpty 
          ? const Center(child: Icon(Icons.image_not_supported, color: Colors.white54))
          : PageView.builder(
              itemCount: mediaUrls.length,
              onPageChanged: (index) {
                setState(() { _currentIndex = index; });
              },
              itemBuilder: (context, index) {
                String url = mediaUrls[index].toString();
                bool isVideo = url.toLowerCase().endsWith('.mp4') || url.toLowerCase().endsWith('.mov') || url.toLowerCase().endsWith('.mkv');
                
                if (isVideo) {
                  return NetworkVideoPlayer(url: url);
                } else {
                  return Image.network(url, fit: BoxFit.cover);
                }
              },
            ),
    );
  }

  Widget _buildCarouselIndicators(List<dynamic> mediaUrls) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          mediaUrls.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index ? Colors.blueAccent : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          InkWell(
            onTap: toggleLike,
            child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : textColor, size: 28),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postId: widget.postId)));
            },
            child: Image.asset('assets/images/comment.png', color: textColor),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: _showShareModal,
            child: Image.asset('assets/images/send.png', color: textColor),
          ),
          Spacer(),
          InkWell(
            onTap: toggleSave,
            child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: textColor, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionSection(Color textColor, String displayUsername, String caption) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$likeCount ${'feed_likes'.tr()}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Text.rich(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                TextSpan(text: '$displayUsername ', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                TextSpan(text: caption, style: TextStyle(color: textColor, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postId: widget.postId)));
            },
            child: Text('${'feed_view_comments'.tr()} ($_commentCount)',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontFamily: 'inter')),
          ),
        ],
      ),
    );
  }
}
