import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/core/profile_cus.dart';
import 'package:instagram_clone/views/profile/user_posts_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color tfColor = isDark ? Colors.grey[900]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'search_hint'.tr(),
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: tfColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) {
            setState(() { _isSearching = val.isNotEmpty; });
          },
        ),
      ),
      body: _isSearching ? _buildUserSearch() : _buildExploreGrid(),
    );
  }

  Widget _buildExploreGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            List<dynamic> mediaUrls = data['mediaUrls'] ?? [];
            if (mediaUrls.isEmpty) return const SizedBox();
            String firstUrl = mediaUrls.first.toString();
            String thumbnailUrl = firstUrl.replaceAll(RegExp(r'\.mp4|\.mov|\.mkv|\.avi'), '.jpg');

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => UserPostsScreen(docs: docs.sublist(index)),
                ));
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(thumbnailUrl, fit: BoxFit.cover),
                  if (mediaUrls.length > 1)
                    const Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(Icons.collections, color: Colors.white, size: 16),
                    ),
                  if (firstUrl.toLowerCase().endsWith('.mp4') || firstUrl.toLowerCase().endsWith('.mov'))
                    const Positioned(
                      bottom: 5,
                      left: 5,
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserSearch() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        List<QueryDocumentSnapshot> matchedUsers = [];
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String username = data['username'] ?? data['name'] ?? 'User';
          if (username.toLowerCase().contains(_searchController.text.toLowerCase())) {
            matchedUsers.add(doc);
          }
        }

        if (matchedUsers.isEmpty) {
          return Center(child: Text('search_no_results'.tr(), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)));
        }

        return ListView.builder(
          itemCount: matchedUsers.length,
          itemBuilder: (context, index) {
            var data = matchedUsers[index].data() as Map<String, dynamic>;
            String uid = matchedUsers[index].id;
            String username = data['username'] ?? data['name'] ?? 'User';
            String url = data['profilePicUrl'] ?? '';
            String bio = data['bio'] ?? '';

            return ListTile(
              dense: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: url.isNotEmpty 
                    ? NetworkImage(url) 
                    : const AssetImage('assets/images/avatar.png') as ImageProvider,
              ),
              title: Text(username, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
              subtitle: bio.isNotEmpty ? Text(bio, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: ProfileCus(uid: uid, username: username),
                )));
              },
            );
          },
        );
      },
    );
  }
}