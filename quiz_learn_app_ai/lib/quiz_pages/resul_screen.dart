import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/answer_card.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/content_area.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/custom_app_bar.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/main_button.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/question_number_card.dart';

class ResultScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? quizData;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>>? allQuestions;
  ResultScreen({super.key,
  this.quizData,
   this.rightAnswers,
  this.wrongAnswers,
  this.allQuestions,});
  

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String>? _rightAnswers;
  List<String>? _wrongAnswers;
  List<Map<dynamic, dynamic>>? _allQuestions;
  Map<dynamic, dynamic>? _quizData;


  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _wrongAnswers = widget.wrongAnswers;
    _allQuestions = widget.allQuestions;
    _quizData = widget.quizData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Column(
          children: [
            CustomAppBar(
              leading: SizedBox(height: 80,),
              title: '${_rightAnswers?.length.toString()} out of ${_allQuestions?.length.toString()} are correct',
            ),
             Expanded(
              child: ContentArea(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: Text("Congratulations!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    Text("You have $points points",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    ),
                    const SizedBox(height: 25),
                    const Text("Right Answers",
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _allQuestions!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Get.width ~/75,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      ),
                        itemBuilder: (_, index){
                          AnswerStatus? answerStatus; 
                      if(_rightAnswers!.contains(_allQuestions![index]['answer'])){
                        answerStatus = AnswerStatus.correct;
                      }
                      else {
                        answerStatus = AnswerStatus.wrong;
                      
                      }
                      return QuestionNumberCard(index: index + 1, status: answerStatus, onTap: () {});
                        }, 
                        ),
                        ),
                        ColoredBox(
                          color: Colors.white,
                          child: Padding(
                            padding: UiParameters.mobileScreenPadding,
                            child: Row(
                              children: [
                                Expanded(child: MainButton(onTap: () {}, 
                                color: Colors.blueGrey,
                                title: "Try again",
                                ),
                              
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: MainButton(onTap: () {
                                  
                                },
                                title: "Go Home",
                                ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),))
          ],
        ))
    );
  }

  Future<void> _saveResult() async {
  try {
    final User? user = _auth.currentUser;
    if (user != null) {
      final newQuizRef = _database
          .child('lecturers')
          .child(user.uid)
          .child('quizzes')
          .push();

      await newQuizRef.set({
        'id': newQuizRef.key,
        'name': _quizData!['name'],
        'subject': _quizData!['subject'],
        'lecturer': _quizData!['lecturer'],
        'questionsCount': _allQuestions!.length,
        'grade': points,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz: ${e.toString()}')),
      );
    }
  }
}

  String get points{
    var points = (_rightAnswers!.length/_allQuestions!.length) * 100;
    return points.toStringAsFixed(2);
  }
}