import 'package:flutter/material.dart';
import 'package:instagram_clone/views/editProfile/widget/biger_text.dart';
import 'package:instagram_clone/views/editProfile/widget/smaller_txt.dart';
import 'package:instagram_clone/views/editProfile/widget/text_field.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leadingWidth: 90,
          leading: TextButton(
              onPressed: () {},
              child: SmallerTxt(txt: 'Cancel', color: Colors.white, size: 16)),
          title: BigerText(
            txt: 'Edit Profile',
            color: Colors.white,
            size: 16,
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: BigerText(
                size: 16,
                txt: 'Done',
                color: Color(0xff3897F0),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
                radius: 50,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            BigerText(
                txt: 'Change Profile Photo',
                color: Color(0xff3897F0),
                size: 13),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Name', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(
                          txt: 'Username', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Website', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Bio', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Divider(
                color: const Color.fromARGB(122, 255, 255, 255),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SmallerTxt(
                      txt: 'Switch to Professional Account',
                      color: Color(0xff3897F0),
                      size: 15),
                  SizedBox(
                    height: 15,
                  ),
                  BigerText(
                      txt: 'Private Information',
                      color: Colors.white,
                      size: 15),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Email', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Phone', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallerTxt(txt: 'Gender', color: Colors.white, size: 15),
                      TextFieldCustom(
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
