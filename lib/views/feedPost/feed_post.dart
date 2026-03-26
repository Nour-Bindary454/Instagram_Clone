import 'package:flutter/material.dart';
import 'package:instagram_clone/core/post.dart';
import 'package:instagram_clone/views/chat/chat.dart';
import 'package:instagram_clone/views/creatPost/creat_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/feedPost/widgets/story_carousel.dart';

class FeedPost extends StatefulWidget {
  FeedPost({super.key, required this.onLikeTap});
  final VoidCallback onLikeTap;
  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () {}, child: Image.asset('assets/images/arrow_down.png'))),
        leadingWidth: 115,
        leading: Padding(padding: const EdgeInsets.only(left: 20), child: Image.asset('assets/images/insta_logo_w.png', color: textColor)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          InkWell(onTap: widget.onLikeTap, child: Image.asset('assets/images/likes.png', color: textColor)),
          const SizedBox(width: 20),
          InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Chat())), child: Image.asset('assets/images/chats.png', color: textColor)),
          const SizedBox(width: 20),
          InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatPost())), child: Image.asset('assets/images/add.png', color: textColor)),
          const SizedBox(width: 20),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: StoryCarousel(textColor: textColor)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.white54)));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SliverFillRemaining(child: Center(child: Text('profile_no_posts'.tr(), style: TextStyle(color: textColor, fontSize: 18))));
              final docs = snapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return Post(snap: data, postId: docs[index].id);
                }, childCount: docs.length),
              );
            }
          ),
        ],
      ),
    );
  }
}
