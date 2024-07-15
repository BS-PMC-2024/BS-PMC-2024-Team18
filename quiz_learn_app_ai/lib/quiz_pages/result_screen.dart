import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/content_area.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/custom_app_bar.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/main_button.dart';
import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? quizData;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>>? allQuestions;

  const ResultScreen({
    super.key,
    this.quizData,
    this.rightAnswers,
    this.wrongAnswers,
    this.allQuestions,
  });

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  List<String>? _rightAnswers;
  List<Map<dynamic, dynamic>>? _allQuestions;
final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _allQuestions = widget.allQuestions;

  }

 Future<void> _saveResults() async {
    try {
      await _firebaseService.saveQuizResults(
        widget.quizData?['id'],
        widget.quizData?['name'],
        _rightAnswers,
        widget.wrongAnswers,
        points,
      );
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz results saved successfully')),
      );}
     
    } catch (e) {
       if(mounted){  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz results: ${e.toString()}')),
      );}
    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Column(
          children: [
            CustomAppBar(
              leading: const SizedBox(height: 80),
              title: '${_rightAnswers?.length.toString()} out of ${_allQuestions?.length.toString()} are correct',
            ),
            Expanded(
              child: ContentArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: Text(
                        "Congratulations!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "You have $points points",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text("Right Answers", textAlign: TextAlign.center),
                    const SizedBox(height: 25),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allQuestions?.length ?? 0,
                        itemBuilder: (_, index) {
                          bool isCorrect = _rightAnswers?.contains(_allQuestions![index]['answer']) == true;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                'Question ${index + 1}: ${_allQuestions![index]['question']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                isCorrect ? 'Correct' : 'Wrong',
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              tileColor: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            ),
                          );
                        },
                      ),
                    ),
                    ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: UiParameters.mobileScreenPadding,
                        child: Row(
                          children: [
                            Expanded(
                              child: MainButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const QuizListScreen()),
                                  );
                                },
                                color: Colors.blueGrey,
                                title: "Try again",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MainButton(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
                                },
                                title: "Go Home",
                              ),
                            ),

                             FloatingActionButton(
      onPressed: _saveResults,
      child: const Icon(Icons.save),
    ),
  
                          ],
                        ),
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

  String get points {
    var points = (_rightAnswers!.length / _allQuestions!.length) * 100;
    return points.toStringAsFixed(2);
  }
}
