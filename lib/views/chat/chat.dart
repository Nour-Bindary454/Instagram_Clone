import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/views/chat/chat_room.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('chat_direct_messages'.tr(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: currentUid.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();
                if (docs.isEmpty) return Center(child: Text('chat_no_users'.tr(), style: TextStyle(color: textColor)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String uid = docs[index].id;
                    String username = data['username'] ?? data['name'] ?? 'User';
                    String url = data['profilePicUrl'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: url.isNotEmpty ? NetworkImage(url) : const AssetImage('assets/images/avatar.png') as ImageProvider,
                      ),
                      title: Text(username, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      subtitle: Text('chat_tap_to_chat'.tr(), style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoom(otherUid: uid, otherUsername: username, otherUrl: url)));
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}