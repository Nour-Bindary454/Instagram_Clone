import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> msgData;
  final String currentUid;

  const ChatBubble({super.key, required this.msgData, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    bool isMe = msgData['senderId'] == currentUid;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          msgData['text'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
