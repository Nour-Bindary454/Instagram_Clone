import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/core/profile_cus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/profile/settings_screen.dart';
import 'package:instagram_clone/views/creatPost/creat_post.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              String title = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User';
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                title = data['username'] ?? data['name'] ?? title;
              }
              return Text(
                title,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                overflow: TextOverflow.ellipsis,
              );
            }
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  if (context.locale.languageCode == 'en') {
                    context.setLocale(const Locale('ar'));
                  } else {
                    context.setLocale(const Locale('en'));
                  }
                },
                icon: Icon(Icons.language, color: Theme.of(context).iconTheme.color)),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatPost()));
                }, icon: Image.asset('assets/images/add.png', color: Theme.of(context).iconTheme.color)),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }, icon: Image.asset('assets/images/menu.png', color: Theme.of(context).iconTheme.color))
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ProfileCus(
            //     widget: SizedBox(
            //   height: 100,
            //   child: Column(
            //     children: [
            //       BButton(height: 40, text: 'Follow', onPressed: () {}),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           ActionButton(onPressed: () {}, text: 'Message'),
            //           ActionButton(onPressed: () {}, text: 'Subscribe'),
            //           ActionButton(onPressed: () {}, text: 'Contact'),
            //           PersonPlusButton(onTap: () {})
            //         ],
            //       ),
            //     ],
            //   ),
            // )
            ));
  }
}
