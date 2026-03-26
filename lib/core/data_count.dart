import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DataCount extends StatelessWidget {
  DataCount({super.key,required this.number,required this.text});
  String number;
  String text;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Text(number,
            style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'inter')),
        Text(text,
            style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'inter')),
      ],
    );
  }
}
