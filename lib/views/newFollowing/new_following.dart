import 'package:flutter/material.dart';
import 'package:instagram_clone/core/profile_cus.dart';

class NewFollowing extends StatefulWidget {
  const NewFollowing({super.key});

  @override
  State<NewFollowing> createState() => _NewFollowingState();
}

class _NewFollowingState extends State<NewFollowing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {},
              icon: Image.asset('assets/images/arrow_back.png')),
          title: Text(
            'username',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'inter',
                color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Image.asset('assets/images/notification.png')),
            IconButton(
                onPressed: () {}, icon: Image.asset('assets/images/more.png'))
          ],
        ),
        backgroundColor: Colors.black,
        body: ProfileCus(
            // widget: SizedBox(),
            // widget: SizedBox(
            //   child: Column(children: [
            //      BButton(height: 40, text: 'Follow', onPressed: () {}),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               ActionButton(onPressed: () {}, text: 'Message'),
            //               ActionButton(onPressed: () {}, text: 'Subscribe'),
            //               ActionButton(onPressed: () {}, text: 'Contact'),
            //               PersonPlusButton(onTap: () {})
            //             ],
            //           ),
            //   ],),
            // ),
            ));
  }
}
