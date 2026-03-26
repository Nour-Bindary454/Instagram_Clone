import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/views/profile/user_posts_screen.dart';
import 'package:instagram_clone/views/profile/edit_profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/story/story_view_screen.dart';
import 'package:instagram_clone/cupits/story/story_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:instagram_clone/views/chat/chat_room.dart';

import 'package:instagram_clone/core/action_button.dart';
import 'package:instagram_clone/core/b_button.dart';
import 'package:instagram_clone/core/data_count.dart';
import 'package:instagram_clone/core/person_plus_button.dart';
import 'package:instagram_clone/core/text.dart';

class ProfileCus extends StatefulWidget {
  final String? uid;
  final String? username;
  const ProfileCus({super.key, this.uid, this.username});

  @override
  State<ProfileCus> createState() => _ProfileCusState();
}

class _ProfileCusState extends State<ProfileCus> {
  int activeTab = 0;
  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _displayDocs = [];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    String displayUid = widget.uid ?? currentUid;
    String displayUsername = widget.username ?? FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User';
    bool isMe = displayUid == currentUid;

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: displayUid).snapshots(),
        builder: (context, postSnapshot) {
          int postCount = 0;

          if (postSnapshot.hasData) {
            _allDocs = postSnapshot.data!.docs.toList();
            postCount = _allDocs.length;
            _allDocs.sort((a, b) {
              Timestamp tA = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
              Timestamp tB = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
              return tB.compareTo(tA);
            });
          }

          _displayDocs = [];
          if (activeTab == 0) {
            _displayDocs = _allDocs;
          } else if (activeTab == 1) {
            _displayDocs = _allDocs.where((d) {
              List<dynamic> media = (d.data() as Map<String, dynamic>)['mediaUrls'] ?? [];
              if (media.isEmpty) return false;
              String url = media.first.toString().toLowerCase();
              return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.mkv');
            }).toList();
          }

          return CustomScrollView(
            slivers: [
              if (!isMe) _buildSliverAppBar(textColor, displayUsername),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileStatsRow(displayUid, displayUsername, isMe, postCount, textColor),
                      _buildProfileDetails(displayUid, displayUsername, textColor),
                      _buildActionButtons(displayUid, currentUid, isMe, displayUsername, textColor),
                      _buildTabBar(textColor),
                    ],
                  ),
                ),
              ),
              _buildPostsGrid(postSnapshot, textColor),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Color textColor, String displayUsername) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(displayUsername, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'inter')),
          const SizedBox(width: 5),
          const Icon(Icons.verified, color: Colors.blue, size: 16),
        ],
      ),
      centerTitle: true,
      actions: [
        Icon(Icons.notifications_none, color: textColor, size: 28),
        const SizedBox(width: 15),
        Icon(Icons.more_horiz, color: textColor, size: 28),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildProfileStatsRow(String displayUid, String displayUsername, bool isMe, int postCount, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAvatarSection(displayUid, isMe),
        _buildDataCounts(displayUid, postCount),
      ],
    );
  }

  Widget _buildAvatarSection(String displayUid, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stories').where('userId', isEqualTo: displayUid).snapshots(),
        builder: (context, storySnapshot) {
          bool hasStory = storySnapshot.hasData && storySnapshot.data!.docs.isNotEmpty;
          List<QueryDocumentSnapshot> myStories = hasStory ? storySnapshot.data!.docs : [];
          if (hasStory) {
            myStories.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          }

          return Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  if (hasStory) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewScreen(stories: myStories)));
                  } else {
                    if (!isMe) return;
                    _pickAddStory();
                  }
                },
                child: Container(
                  padding: hasStory ? const EdgeInsets.all(3) : EdgeInsets.zero,
                  decoration: hasStory ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.red, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ) : null,
                  child: Container(
                    padding: hasStory ? const EdgeInsets.all(2) : EdgeInsets.zero,
                    decoration: hasStory ? BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle) : null,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(displayUid).snapshots(),
                      builder: (context, avatarSnapshot) {
                        String url = '';
                        if (avatarSnapshot.hasData && avatarSnapshot.data!.exists) {
                          url = (avatarSnapshot.data!.data() as Map<String, dynamic>)['profilePicUrl'] ?? '';
                        }
                        return CircleAvatar(
                          radius: 35,
                          backgroundImage: url.isNotEmpty ? NetworkImage(url) : const AssetImage('assets/images/profile.png') as ImageProvider,
                        );
                      }
                    ),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAddStory,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
                      child: const CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Icon(Icons.add, color: Colors.white, size: 18)),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _pickAddStory() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickMedia();
    if (media != null && mounted) {
      context.read<StoryCubit>().addStory(File(media.path));
    }
  }

  Widget _buildDataCounts(String displayUid, int postCount) {
    return Expanded(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(displayUid).snapshots(),
        builder: (context, userSnapshot) {
          List<dynamic> followers = [];
          List<dynamic> following = [];
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var data = userSnapshot.data!.data() as Map<String, dynamic>;
            followers = data['followers'] ?? [];
            following = data['following'] ?? [];
          }
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DataCount(number: postCount.toString(), text: 'profile_posts'.tr()),
              DataCount(number: followers.length.toString(), text: 'profile_followers'.tr()),
              DataCount(number: following.length.toString(), text: 'profile_following'.tr()),
            ],
          );
        }
      ),
    );
  }

  Widget _buildProfileDetails(String displayUid, String displayUsername, Color textColor) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(displayUid).snapshots(),
      builder: (context, userSnapshot) {
        String name = displayUsername;
        String bio = '';
        String website = '';
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var data = userSnapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? data['username'] ?? displayUsername;
          bio = data['bio'] ?? '';
          website = data['website'] ?? '';
          if (name.isEmpty) name = displayUsername;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(color: textColor, fontWeight: FontWeight.w700, text: name),
            if (bio.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 2), child: TextCustom(color: textColor, fontWeight: FontWeight.w400, text: bio)),
            if (website.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 2), child: TextCustom(color: const Color(0xff004C8B), fontWeight: FontWeight.w700, text: website)),
          ],
        );
      }
    );
  }

  Widget _buildActionButtons(String displayUid, String currentUid, bool isMe, String displayUsername, Color textColor) {
    return Column(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(displayUid).snapshots(),
          builder: (context, btnSnapshot) {
            bool isFollowing = false;
            if (btnSnapshot.hasData && btnSnapshot.data!.exists) {
              var data = btnSnapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> followers = data['followers'] ?? [];
              isFollowing = followers.contains(currentUid);
            }

            return BButton(
              height: 40,
              color: (isMe || isFollowing) ? Colors.grey[800] : Colors.blue,
              text: isMe ? 'profile_edit'.tr() : (isFollowing ? 'profile_following_status'.tr() : 'profile_follow'.tr()),
              onPressed: () => _handleFollowAction(isMe, isFollowing, displayUid, currentUid)
            );
          }
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionButton(
              onPressed: () async {
                var doc = await FirebaseFirestore.instance.collection('users').doc(displayUid).get();
                String url = doc.exists ? ((doc.data() as Map<String, dynamic>)['profilePicUrl'] ?? '') : '';
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoom(otherUid: displayUid, otherUsername: displayUsername, otherUrl: url)));
              }, 
              text: 'profile_message'.tr()
            ),
            ActionButton(onPressed: () {}, text: 'profile_subscribe'.tr()),
            ActionButton(onPressed: () {}, text: 'profile_contact'.tr()),
            PersonPlusButton(onTap: () {})
          ],
        ),
      ],
    );
  }

  Future<void> _handleFollowAction(bool isMe, bool isFollowing, String displayUid, String currentUid) async {
    if (isMe) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
      return;
    }
    DocumentReference targetUserRef = FirebaseFirestore.instance.collection('users').doc(displayUid);
    DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUid);

    if (isFollowing) {
      await targetUserRef.set({'followers': FieldValue.arrayRemove([currentUid])}, SetOptions(merge: true));
      await currentUserRef.set({'following': FieldValue.arrayRemove([displayUid])}, SetOptions(merge: true));
    } else {
      await targetUserRef.set({'followers': FieldValue.arrayUnion([currentUid])}, SetOptions(merge: true));
      await currentUserRef.set({'following': FieldValue.arrayUnion([displayUid])}, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(displayUid).collection('notifications').add({
        'type': 'follow',
        'userId': currentUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Widget _buildTabBar(Color textColor) {
    return DefaultTabController(
      length: 3,
      initialIndex: activeTab,
      child: SizedBox(
        width: double.infinity,
        height: 30,
        child: TabBar(
          onTap: (val) { setState(() { activeTab = val; }); },
          unselectedLabelColor: const Color(0xffC4C4C4),
          indicatorColor: textColor,
          tabs: [
            Image.asset('assets/images/grid.png', color: activeTab == 0 ? textColor : Colors.grey),
            Image.asset('assets/images/reels.png', color: activeTab == 1 ? textColor : Colors.grey),
            Image.asset('assets/images/tags.png', color: activeTab == 2 ? textColor : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(AsyncSnapshot<QuerySnapshot> postSnapshot, Color textColor) {
    if (postSnapshot.connectionState == ConnectionState.waiting) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.grey)));
    }
    if (_displayDocs.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text('profile_no_posts'.tr(), style: TextStyle(color: textColor, fontSize: 18))));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var data = _displayDocs[index].data() as Map<String, dynamic>;
          List<dynamic> mediaUrls = data['mediaUrls'] ?? [];
          if (mediaUrls.isEmpty) return Container(color: Colors.black12);

          String firstUrl = mediaUrls.first.toString();
          String thumbnailUrl = firstUrl.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => UserPostsScreen(docs: _displayDocs.sublist(index)),
              ));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(thumbnailUrl, fit: BoxFit.cover),
                if (mediaUrls.length > 1)
                  const Positioned(top: 5, right: 5, child: Icon(Icons.collections, color: Colors.white, size: 16)),
                if (firstUrl.toLowerCase().endsWith('.mp4') || firstUrl.toLowerCase().endsWith('.mov'))
                  const Positioned(bottom: 5, left: 5, child: Icon(Icons.play_arrow, color: Colors.white, size: 20)),
              ],
            ),
          );
        },
        childCount: _displayDocs.length,
      ),
    );
  }
}
