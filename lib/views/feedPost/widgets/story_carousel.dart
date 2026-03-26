import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:instagram_clone/cupits/story/story_cubit.dart';
import 'package:instagram_clone/views/story/story_view_screen.dart';

class StoryCarousel extends StatelessWidget {
  final Color textColor;

  const StoryCarousel({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stories').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          List<QueryDocumentSnapshot> allStories = snapshot.hasData ? snapshot.data!.docs : [];
          String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          
          Map<String, List<QueryDocumentSnapshot>> userStories = {};
          for (var doc in allStories) {
            var data = doc.data() as Map<String, dynamic>;
            String uid = data['userId'] ?? '';
            if (uid.isNotEmpty) {
              userStories.putIfAbsent(uid, () => []).add(doc);
            }
          }

          List<String> uniqueUserIds = userStories.keys.where((id) => id != currentUid).toList();
          int itemCount = 1 + uniqueUserIds.length;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                bool hasMyStory = userStories.containsKey(currentUid);
                return GestureDetector(
                  onTap: () async {
                    if (hasMyStory) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewScreen(stories: userStories[currentUid]!)));
                    } else {
                      final ImagePicker picker = ImagePicker();
                      final XFile? media = await picker.pickMedia();
                      if (media != null && context.mounted) {
                        context.read<StoryCubit>().addStory(File(media.path));
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: hasMyStory ? const EdgeInsets.all(3) : EdgeInsets.zero,
                              decoration: hasMyStory ? const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.red, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ) : null,
                              child: Container(
                                padding: hasMyStory ? const EdgeInsets.all(2) : EdgeInsets.zero,
                                decoration: hasMyStory ? const BoxDecoration(color: Colors.black, shape: BoxShape.circle) : null,
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
                                  builder: (context, userSnapshot) {
                                    String url = '';
                                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                      url = (userSnapshot.data!.data() as Map<String, dynamic>)['profilePicUrl'] ?? '';
                                    }
                                    return CircleAvatar(
                                      radius: hasMyStory ? 30 : 35,
                                      backgroundImage: url.isNotEmpty ? NetworkImage(url) : const AssetImage('assets/images/avatar.png') as ImageProvider,
                                    );
                                  }
                                ),
                              ),
                            ),
                            if (!hasMyStory)
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('Your Story', style: TextStyle(color: textColor, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }

              String userId = uniqueUserIds[index - 1];
              var firstStoryData = userStories[userId]!.first.data() as Map<String, dynamic>;
              String username = firstStoryData['username'] ?? 'User';

              return GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewScreen(stories: userStories[userId]!)));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                            builder: (context, userSnapshot) {
                              String url = '';
                              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                url = (userSnapshot.data!.data() as Map<String, dynamic>)['profilePicUrl'] ?? '';
                              }
                              return CircleAvatar(
                                radius: 30,
                                backgroundImage: url.isNotEmpty ? NetworkImage(url) : const AssetImage('assets/images/avatar.png') as ImageProvider,
                              );
                            }
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(username, style: TextStyle(color: textColor, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
