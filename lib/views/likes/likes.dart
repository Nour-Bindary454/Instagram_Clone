import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/likes/widgets/activity_tile.dart';

class Likes extends StatefulWidget {
  const Likes({super.key});

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: TabBar(
            dividerColor: Colors.transparent,
            labelColor: textColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: textColor,
            tabs: [
              Tab(text: 'activity_following_tab'.tr()),
              Tab(text: 'activity_you_tab'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('activity_empty_following'.tr(), style: const TextStyle(color: Colors.grey))),
            _buildYouTab(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTab(Color textColor) {
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUid.isEmpty) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('notifications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading activity...', style: TextStyle(color: Colors.red)));
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: textColor));
        
        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          Timestamp? tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          Timestamp? tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          return (tB ?? Timestamp.now()).compareTo(tA ?? Timestamp.now());
        });
        
        if (docs.isEmpty) return Center(child: Text('activity_empty_you'.tr(), style: TextStyle(color: textColor)));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String userId = data['userId'] ?? '';
            if (userId.isEmpty) return const SizedBox();
            return ActivityTile(data: data, userId: userId, textColor: textColor);
          }
        );
      }
    );
  }
}
