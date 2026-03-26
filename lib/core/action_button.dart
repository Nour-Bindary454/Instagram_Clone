import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  ActionButton({super.key, required this.onPressed, required this.text});
  final void Function() onPressed;
  String text;
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color btnColor = isDark ? const Color.fromARGB(255, 71, 70, 70) : Colors.grey[300]!;

    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          // fixedSize: Size(90, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontFamily: 'inter',
              fontSize: 8.62,
              fontWeight: FontWeight.w700,
              color: textColor),
        ));
  }
}
