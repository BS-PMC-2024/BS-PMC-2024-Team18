import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';

enum AnswerStatus{
  correct,
  wrong,
  notSelected,
  selected,
}

class AnswerCard extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final VoidCallback onTap;
  const AnswerCard({super.key, required this.answer, this.isSelected = false, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: UiParameters.cardBorderRadius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple.withOpacity(0.5):Colors.white,
        borderRadius: UiParameters.cardBorderRadius,
        border: Border.all(
          color: isSelected ? Colors.purple:Colors.white,
          
      ),
      ),
        child: Text(
        answer,
        style: TextStyle(
          color: isSelected ?Colors.blue:null,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          
        ),
      ),
    ),
  );
  }
}