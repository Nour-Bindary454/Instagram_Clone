import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/chat/widgets/chat_bubble.dart';
import 'package:instagram_clone/views/chat/widgets/chat_input_field.dart';

class ChatRoom extends StatefulWidget {
  final String otherUid;
  final String otherUsername;
  final String otherUrl;
  const ChatRoom({super.key, required this.otherUid, required this.otherUsername, required this.otherUrl});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _msgController = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late String chatId;
  late CollectionReference _chatRef;

  @override
  void initState() {
    super.initState();
    List<String> ids = [currentUid, widget.otherUid];
    ids.sort();
    chatId = ids.join('_');
    _chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    String text = _msgController.text.trim();
    _msgController.clear();
    
    await _chatRef.add({
      'senderId': currentUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUrl.isNotEmpty ? NetworkImage(widget.otherUrl) : const AssetImage('assets/images/avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUsername, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatRef.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('chat_start_conversation'.tr(), style: const TextStyle(color: Colors.grey)));
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msgData = messages[index].data() as Map<String, dynamic>;
                    return ChatBubble(msgData: msgData, currentUid: currentUid);
                  },
                );
              },
            ),
          ),
          ChatInputField(controller: _msgController, onSend: _sendMessage),
        ],
      ),
    );
  }
}
