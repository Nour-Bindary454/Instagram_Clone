import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/reels/widgets/reel_item.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('search_no_results'.tr(),
                    style: const TextStyle(color: Colors.white)));
          }

          List<QueryDocumentSnapshot> videoDocs =
              snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            List<dynamic> mediaUrls = data['mediaUrls'] ?? [];
            if (mediaUrls.isEmpty) return false;
            String firstUrl = mediaUrls.first.toString().toLowerCase();
            return firstUrl.endsWith('.mp4') ||
                firstUrl.endsWith('.mov') ||
                firstUrl.endsWith('.mkv') ||
                firstUrl.endsWith('.avi');
          }).toList();

          if (videoDocs.isEmpty) {
            return Center(
                child: Text('search_no_results'.tr(),
                    style: const TextStyle(color: Colors.white)));
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videoDocs.length,
            itemBuilder: (context, index) {
              return ReelItem(
                  doc: videoDocs[index], pageController: _pageController);
            },
          );
        },
      ),
    );
  }
}
