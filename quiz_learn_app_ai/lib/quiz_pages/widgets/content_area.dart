import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:get/get.dart';

class ContentArea extends StatelessWidget{
  final bool addPadding;
  final Widget child;
  const ContentArea({super.key,
    required this.child,
    this.addPadding = true});

  @override
  Widget build(BuildContext context) {
    return  Material(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.hardEdge,
      type: MaterialType.transparency,
      child: Ink(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(173, 216, 230, 0.3),
        ),
        padding: addPadding ?  EdgeInsets.only(
          top: mobileScreenPadding,
          left: mobileScreenPadding,
          right: mobileScreenPadding) : EdgeInsets.zero,
          child: child,
      ),
    );
  }
}