import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/result_screen.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/content_area.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/countdown_timer.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/custom_app_bar.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/main_button.dart';

class TestOverviewScreen extends StatelessWidget {
  final String? titleText;
  final String? timeRemaining;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>>? allQuestions;
  final Timer? timer;
  final Map<dynamic, dynamic>? quizData;

  const TestOverviewScreen({
    super.key,
    this.titleText,
    this.timeRemaining,
    this.rightAnswers,
    this.wrongAnswers,
    this.allQuestions,
    this.timer,
    this.quizData,
  });

  bool _allQuestionsAnswered() {
    return (rightAnswers?.length ?? 0) + (wrongAnswers?.length ?? 0) ==
        (allQuestions?.length ?? 0);
  }

  void _showIncompleteAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Please answer all questions before completing the test.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> qData = quizData!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: titleText ?? 'Test Overview',
        time: '',
        showBackButton: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf2b39b),
              Color(0xFFf19b86),
              Color(0xFFf3a292),
              Color(0xFFf8c18e),
              Color(0xFFfcd797),
              Color(0xFFcdd7a7),
              Color(0xFF8fb8aa),
              Color(0xFF73adbb),
              Color(0xFFcc7699),
              Color(0xFF84d9db),
              Color(0xFF85a8cf),
              Color(0xFF8487ac),
              Color(0xFFb7879c),
              Color(0xFF86cfd6),
            ],
          ),
        ),
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
                        Text(
                          '$timeRemaining Remaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allQuestions?.length ?? 0,
                        itemBuilder: (_, index) {
                          bool isCorrect = rightAnswers
                                  ?.contains(allQuestions![index]['answer']) ==
                              true;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                'Question ${index + 1}: ${allQuestions![index]['question']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                isCorrect ? 'Correct' : 'Wrong',
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              tileColor: isCorrect
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: UiParameters.mobileScreenPadding,
                      child: MainButton(
                        onTap: () {
                          if (_allQuestionsAnswered()) {
                            timer?.cancel();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultScreen(
                                  quizData: qData,
                                  rightAnswers: rightAnswers!,
                                  wrongAnswers: wrongAnswers!,
                                  allQuestions: allQuestions!,
                                ),
                              ),
                            );
                          } else {
                            _showIncompleteAlert(context);
                          }
                        },
                        title: "Complete",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
