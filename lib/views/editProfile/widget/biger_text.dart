import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BigerText extends StatelessWidget {
  BigerText({super.key, required this.txt, required this.color,required this.size});
  String txt;
  Color color;
  double size;
  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
          color: color,
          fontFamily: 'inter',
          fontSize: size,
          fontWeight: FontWeight.w600),
    );
  }
}
