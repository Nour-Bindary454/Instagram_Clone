import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/views/feedPost/feed_post.dart';
import 'package:instagram_clone/views/likes/likes.dart';
import 'package:instagram_clone/views/profile/profile.dart';
import 'package:instagram_clone/views/reels/reels.dart';
import 'package:instagram_clone/views/search/search.dart';
import 'package:instagram_clone/views/favorite/favorite_screen.dart';

class MainLayOut extends StatefulWidget {
  const MainLayOut({super.key});

  @override
  State<MainLayOut> createState() => _MainLayOutState();
}

class _MainLayOutState extends State<MainLayOut> {
  int selectedIndex = 0;
  bool isLikesVisible = false;
  void navigateToLikes() {
    setState(() {
      selectedIndex = 3;
      isLikesVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      FeedPost(
        onLikeTap: navigateToLikes,
      ),
      Search(),
      Reels(),
      isLikesVisible ? Likes() : const FavoriteScreen(),
      Profile()
    ];
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          selectedIconTheme:
              CupertinoIconThemeData(color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor, fill: 1),
          iconSize: 25,
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
              if (value == 3) isLikesVisible = false;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/images/home.png')),
                label: ''),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/images/search.png')),
                label: ''),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/images/reels.png')),
                label: ''),
            BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_border),
                activeIcon: const Icon(Icons.bookmark),
                label: ''),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/images/avatar.png'),
                ),
                label: ''),
          ]),
    );
  }
}
