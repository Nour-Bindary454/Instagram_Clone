import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TxtField extends StatelessWidget {
  TxtField(
      {super.key,
      required this.color,
      required this.hint,
      required this.hintColor,
      required this.obscureText,
      required this.controller});
  Color color;
  String hint;
  Color hintColor;
  bool obscureText;
  TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
            style: TextStyle(color: hintColor),
            obscureText: obscureText,
            obscuringCharacter: '*',
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontFamily: 'inter'),
            )));
  }
}
