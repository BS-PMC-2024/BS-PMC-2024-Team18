import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/question_screen.dart';
import 'package:quiz_learn_app_ai/quiz_pages/resul_screen.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/answer_card.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/content_area.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/countdown_timer.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/custom_app_bar.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/main_button.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/question_number_card.dart';
import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';

class TestOverviewScreen extends StatelessWidget{
  final String? titleText;
  final String? timeRemaining;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>>? allQuestions;
  final Timer? timer;
  final Map<dynamic, dynamic>? quizData;

  const TestOverviewScreen({super.key,
  this.titleText,
  this.timeRemaining,
  this.rightAnswers,
  this.wrongAnswers,
  this.allQuestions,
  this.timer,
  this.quizData,
  });

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> _qData = quizData!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: titleText??'Test Overview', time: '',
      ),
      body:   BackgroundDecoration(
        child: Column(
          children: [
            Expanded(
              child: ContentArea(
                child: Column(
                  children: [
                    Row(
                  children: [
                    const CountdownTimer(
                      color: Colors.white,
                      time: '',
                    ),
                    
                    Text('$timeRemaining Remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),),
                    
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: allQuestions!.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Get.width ~/75,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      ),
                    itemBuilder: (_, index){
                      AnswerStatus? _answerStatus; 
                      if(rightAnswers!.contains(allQuestions![index]['answer'])){
                        _answerStatus = AnswerStatus.correct;
                      }
                      else {
                        _answerStatus = AnswerStatus.wrong;
                      
                      }
                      return QuestionNumberCard(index: index + 1, status: _answerStatus, onTap: () {});
                    },),
                ),
                ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: UiParameters.mobileScreenPadding,
                    child: MainButton(
                      onTap:  () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ResultScreen(
                        quizData: _qData,
                        rightAnswers: rightAnswers!,
                        wrongAnswers: wrongAnswers!,
                        allQuestions: allQuestions!,
                      ))),
                    
                      title: "Complete",
                    ),
                    
                  ),
                )
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}