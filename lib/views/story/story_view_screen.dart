import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryViewScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> stories;

  const StoryViewScreen({super.key, required this.stories});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    // Reverse the descending timestamp so we view oldest story first (chronological order)
    for (var doc in widget.stories.reversed) {
      var data = doc.data() as Map<String, dynamic>;
      String url = data['mediaUrl'] ?? '';
      String type = data['type'] ?? 'image';

      if (url.isNotEmpty) {
        if (type == 'video') {
          storyItems.add(StoryItem.pageVideo(url, controller: controller));
        } else {
          storyItems.add(StoryItem.pageImage(url: url, controller: controller));
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (storyItems.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("No valid stories found.", style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: StoryView(
        storyItems: storyItems,
        controller: controller,
        repeat: false,
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
