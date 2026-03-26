import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextFieldCustom extends StatelessWidget {
  TextFieldCustom({super.key,required this.controller});
TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: TextField(
          controller:controller ,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'inter',
                fontSize: 16,
                fontWeight: FontWeight.w400)));
  }
}
