import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/answer_card.dart';

class QuestionNumberCard extends StatelessWidget{
  const QuestionNumberCard({super.key, required this.index, required this.status, required this.onTap});
  final int index;
  final AnswerStatus? status;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = Colors.white;
    switch (status) {
      case AnswerStatus.correct:
        _backgroundColor = Colors.green;
        break;
      case AnswerStatus.wrong:
        _backgroundColor = Colors.red.withOpacity(0.5);
       break;
      case AnswerStatus.selected:
        _backgroundColor = Colors.blue;
        break;
      case AnswerStatus.notSelected:
        _backgroundColor = Colors.lightBlue.withOpacity(0.5);
        break;
      default:   
        _backgroundColor = Colors.white;
    }
    return InkWell(
      borderRadius: UiParameters.cardBorderRadius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: UiParameters.cardBorderRadius,
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Center(
          child: Text(
            '$index',
            style: TextStyle(
              color: status == AnswerStatus.notSelected?Colors.blue:null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            ),
            ),

      ),
    );
  }
}

