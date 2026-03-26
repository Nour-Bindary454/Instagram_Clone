import 'package:flutter/material.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;
  final Color textColor;
  final bool isDark;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.isPosting,
    required this.onPost,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
              onPressed: isPosting ? null : onPost,
              child: isPosting
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2))
                  : const Text('Post', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
