import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class TextCustom extends StatelessWidget {
  TextCustom(
      {super.key,
      required this.color,
      required this.fontWeight,
      required this.text});
  FontWeight fontWeight;
  Color color;
  String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: fontWeight,
          fontFamily: 'inter',
          color: color),
    );
  }
}
