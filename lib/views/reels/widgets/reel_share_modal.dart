import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class ReelShareModal {
  static void show(BuildContext context, QueryDocumentSnapshot doc) {
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
                        var docs = snapshot.data!.docs.where((d) => d.id != currentUid).toList();
                        if (docs.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: Colors.white)));
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var uData = docs[index].data() as Map<String, dynamic>;
                            String uid = docs[index].id;
                            String username = uData['username'] ?? uData['name'] ?? 'User';
                            String url = uData['profilePicUrl'] ?? '';
                            return GestureDetector(
                              onTap: () async {
                                List<String> ids = [currentUid, uid];
                                ids.sort();
                                String chatId = ids.join('_');
                                var data = doc.data() as Map<String, dynamic>;
                                List<dynamic> mediaUrls = data['mediaUrls'] ?? [];
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
                                    CircleAvatar(
                                        radius: 30,
                                        backgroundImage: url.isNotEmpty
                                            ? NetworkImage(url)
                                            : const AssetImage('assets/images/avatar.png') as ImageProvider),
                                    const SizedBox(height: 8),
                                    Text(username.length > 8 ? '${username.substring(0, 8)}...' : username,
                                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
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
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
  }
}
