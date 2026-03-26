import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonPlusButton extends StatelessWidget {
  const PersonPlusButton({super.key,required this.onTap});
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return  InkWell(
                            onTap: onTap,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 71, 70, 70),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Image.asset('assets/images/plus.png'),
                            ),
                          );
  }
}