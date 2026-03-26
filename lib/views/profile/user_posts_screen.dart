import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/core/post.dart';

class UserPostsScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const UserPostsScreen({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Posts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          var snap = docs[index].data() as Map<String, dynamic>;
          return Post(snap: snap, postId: docs[index].id);
        },
      ),
    );
  }
}
