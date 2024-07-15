

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/test_overwiew_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? time;
  final String title;
  final bool showActionIcon;
  final Widget? titleWidget;
  final Widget? leading;
  final VoidCallback? onMenuActionTap;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>>? allQuestions;
  final Timer? timer;
  

  const CustomAppBar({
    super.key,
    this.time,
    this.title = '',
    this.showActionIcon = false,
    this.onMenuActionTap,
    this.titleWidget,
    this.leading,
    this.rightAnswers,
    this.wrongAnswers,
    this.allQuestions,
    this.timer,
  });

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(child: Padding(
      padding:  EdgeInsets.symmetric(
        horizontal: mobileScreenPadding,
        vertical: mobileScreenPadding,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: titleWidget == null ? Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ): Center(
            child: titleWidget,
          ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading ?? Transform.translate(offset: const Offset(-14, 0),
              child: const BackButton(color: Colors.white,),
              ),
              if(showActionIcon) Transform.translate(
                offset: const Offset(10, 0),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: onMenuActionTap??(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestOverviewScreen(
                        
                        allQuestions: allQuestions,
                        rightAnswers: rightAnswers,
                        wrongAnswers: wrongAnswers,
                        timeRemaining: time,
                      )),
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    ),
    );
  }
  
  @override
  Size get preferredSize => const Size(
    double.maxFinite,
    90
  );
}