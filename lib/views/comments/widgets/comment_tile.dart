import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> doc;
  final Color textColor;

  const CommentTile({super.key, required this.doc, required this.textColor});

  @override
  Widget build(BuildContext context) {
    String text = doc['text'] ?? '';
    String uname = doc['username'] ?? 'User';
    String pic = doc['profilePicUrl'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : const AssetImage('assets/images/profile.png') as ImageProvider,
      ),
      title: Text(uname, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
