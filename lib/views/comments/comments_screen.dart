import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/comments/widgets/comment_tile.dart';
import 'package:instagram_clone/views/comments/widgets/comment_input_field.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool isPosting = false;

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() { isPosting = true; });

    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String username = 'User';
      String profilePic = '';
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        username = data['username'] ?? data['name'] ?? 'User';
        profilePic = data['profilePicUrl'] ?? '';
      }

      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
        'uid': uid,
        'username': username,
        'profilePicUrl': profilePic,
        'text': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot postDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
      if (postDoc.exists) {
        var pData = postDoc.data() as Map<String, dynamic>;
        String postOwnerId = pData['userId'] ?? '';
        List<dynamic> media = pData['mediaUrls'] ?? [];
        String postUrl = media.isNotEmpty ? media.first.toString() : '';

        if (postOwnerId != uid) {
          await FirebaseFirestore.instance.collection('users').doc(postOwnerId).collection('notifications').add({
            'type': 'comment',
            'userId': uid,
            'commentText': _commentController.text.trim(),
            'postUrl': postUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
      _commentController.clear();
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() { isPosting = false; });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('feed_comments'.tr(), style: TextStyle(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: textColor));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return CommentTile(doc: doc, textColor: textColor);
                  },
                );
              },
            ),
          ),
          CommentInputField(
            controller: _commentController,
            isPosting: isPosting,
            onPost: _postComment,
            textColor: textColor,
            isDark: isDark,
          )
        ],
      ),
    );
  }
}
