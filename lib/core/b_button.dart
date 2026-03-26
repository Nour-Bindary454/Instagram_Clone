import 'package:flutter/material.dart';
import 'package:instagram_clone/core/colors.dart';

// ignore: must_be_immutable
class BButton extends StatelessWidget {
  BButton({super.key, required this.text, required this.onPressed, required this.height, this.color});
  String text;
  final void Function() onPressed;
  double height;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? primaryColor,
        fixedSize: Size(MediaQuery.of(context).size.width * 0.9, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
            fontFamily: 'inter',
            color: Colors.white,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
