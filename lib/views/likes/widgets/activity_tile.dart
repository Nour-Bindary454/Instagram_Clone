import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/core/profile_cus.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String userId;
  final Color textColor;

  const ActivityTile({
    super.key,
    required this.data,
    required this.userId,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    String type = data['type'] ?? '';
    String postUrl = data['postUrl'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox();
        var userData = userSnap.data!.data() as Map<String, dynamic>;
        String username = userData['username'] ?? 'User';
        String avatarUrl = userData['profilePicUrl'] ?? '';

        Widget trailingWidget = const SizedBox();
        String actionText = '';
        
        if (type == 'like') {
          actionText = 'activity_liked'.tr();
          if (postUrl.isNotEmpty) {
            String thumb = postUrl.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');
            trailingWidget = Image.network(thumb, width: 40, height: 40, fit: BoxFit.cover);
          }
        } else if (type == 'comment') {
          String commentText = data['commentText'] ?? '';
          actionText = 'activity_commented'.tr() + ' "$commentText"';
          if (postUrl.isNotEmpty) {
            String thumb = postUrl.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');
            trailingWidget = Image.network(thumb, width: 40, height: 40, fit: BoxFit.cover);
          }
        } else if (type == 'follow') {
          actionText = 'activity_followed'.tr();
          trailingWidget = ElevatedButton(
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                 backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                 body: ProfileCus(uid: userId, username: username),
               )));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(60, 30)),
            child: Text('profile_message'.tr(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          );
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : const AssetImage('assets/images/avatar.png') as ImageProvider,
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: username, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                TextSpan(text: ' $actionText', style: TextStyle(color: textColor)),
              ]
            )
          ),
          trailing: trailingWidget,
          onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
               body: ProfileCus(uid: userId, username: username),
             )));
          },
        );
      }
    );
  }
}
