import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:quiz_learn_app_ai/quiz_pages/configs/ui_parameters.dart';
import 'package:quiz_learn_app_ai/quiz_pages/test_overview_screen.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/answer_card.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/content_area.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/countdown_timer.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/custom_app_bar.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/main_button.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/question_place_holder.dart';

class QuestionScreen extends StatefulWidget {
  final String quizId;
  final String quizName;

  const QuestionScreen({
    super.key,
    required this.quizId,
    required this.quizName,
  });

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String _selectedAnswer = '';
  //late TextEditingController _quizNameController;
  late List<Map<dynamic, dynamic>> _questions = [];
  late Map<dynamic, dynamic> _quizData = {};
  late List<Map<dynamic, dynamic>> _allQuizzes = [];
  bool _isLoading = true;
  bool _isCompleted = false;
  Map<dynamic, dynamic> _currentQuestion = {};
  int _currentQuestionIndex = 0;
  bool get isFirstQuestion => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  int remainSeconds = 1;
  var time = '00.00';
  final List<String> _rightAnswers = [];
  final List<String> _wrongAnswers = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(900);
    _loadQuizDetails();
  }

  void _startTimer(int seconds) {
    remainSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainSeconds > 0) {
        setState(() {
          remainSeconds--;
          time = _formatTime(remainSeconds);
        });
      } else {
        timer.cancel();
        submitTest();
        setState(() {
          _isCompleted = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuizDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _database.child('lecturers').get();

      if (snapshot.exists) {
        _currentQuestionIndex = 0;
        final data = snapshot.value as Map<dynamic, dynamic>;
        _allQuizzes = [];
        data.forEach((lecturerId, lecturerData) {
          if (lecturerData['quizzes'] != null) {
            final quizzes = lecturerData['quizzes'] as Map<dynamic, dynamic>;
            quizzes.forEach((quizId, quizData) {
              // Create a copy of questions and remove the last question
              List<dynamic> questions = List.from(quizData['questions']);
              if (questions.isNotEmpty) {
                questions.removeLast();
              }

              _allQuizzes.add({
                'id': quizId,
                'name': quizData['name'],
                'subject': quizData['subject'],
                'createdAt': quizData['createdAt'],
                'questions': questions, // Use modified questions
                'questionCount': questions.length,
                'lecturer': lecturerData['name'] ?? 'Unknown Lecturer',
                'lecturerId': lecturerId,
              });
            });
          }
        });

        _quizData =
            _allQuizzes.firstWhere((element) => element['id'] == widget.quizId);
        _questions = List<Map<dynamic, dynamic>>.from(_quizData['questions']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading quiz details: ${e.toString()}')),
        );
        if (kDebugMode) {
          print("Error loading quiz details: ${e.toString()}");
        }
      }
    } finally {
      setState(() {
        _isLoading = false;

        _currentQuestion = _questions[_currentQuestionIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        rightAnswers: _rightAnswers,
        wrongAnswers: _wrongAnswers,
        allQuestions: _questions,
        timer: _timer,
        time: time,
        leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            child: CountdownTimer(
              time: time,
              color: Colors.white,
            )),
        showActionIcon: true,
        titleWidget: Text(
          '               Q. ${(_currentQuestionIndex + 1).toString().padLeft(2, '0')}/${_questions.length} - ${_quizData['name']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
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
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                if (_isLoading)
                  const Expanded(
                    child: ContentArea(
                      child: QuestionScreenHolder(),
                    ),
                  ),
                if (!_isLoading)
                  Expanded(
                    child: ContentArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 25,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 5,
                              color: Colors.indigo[150],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                  child: Text(
                                    _questions[_currentQuestionIndex]
                                            ['question']
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.indigo[900],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(top: 25),
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final answer =
                                    _currentQuestion['options'][index];

                                return AnswerCard(
                                    answer: answer,
                                    onTap: () {
                                      selectedAnswer(answer);
                                    },
                                    isSelected: _selectedAnswer == answer);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 20);
                              },
                              itemCount: _questions[_currentQuestionIndex]
                                      ['options']
                                  .length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ColoredBox(
                  color: Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: UiParameters.mobileScreenPadding,
                    child: Row(
                      children: [
                        Visibility(
                          visible: isFirstQuestion,
                          child: SizedBox(
                            width: 55,
                            height: 55,
                            child: MainButton(
                              onTap: previousQuestion,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.indigo[900],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Visibility(
                              visible: !_isCompleted,
                              child: MainButton(
                                onTap: isLastQuestion
                                    ? () {
                                        if (_selectedAnswer.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please select an answer before proceeding.'),
                                            ),
                                          );
                                          return;
                                        }
                                        submitTest();
                                        _timer?.cancel();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TestOverviewScreen(
                                              titleText: completedTest,
                                              timeRemaining: time,
                                              rightAnswers: _rightAnswers,
                                              wrongAnswers: _wrongAnswers,
                                              allQuestions: _questions,
                                              quizData: _quizData,
                                            ),
                                          ),
                                        );
                                      }
                                    : nextQuestion,
                                title: isLastQuestion
                                    ? 'Submit Quiz'
                                    : 'Next Question',
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectedAnswer(String? answer) {
    setState(() {
      _selectedAnswer = answer!;
    });
  }

  void submitTest() {
    setState(() {
      if (_selectedAnswer == _currentQuestion['answer']) {
        _rightAnswers.add(_selectedAnswer);
      }
      if (_selectedAnswer != _currentQuestion['answer']) {
        _wrongAnswers.add(_selectedAnswer);
      }
    });
  }

  void nextQuestion() {
    if (_selectedAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before proceeding.'),
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        if (_selectedAnswer == _currentQuestion['answer']) {
          _rightAnswers.add(_selectedAnswer);
        } else {
          _wrongAnswers.add(_selectedAnswer);
        }
        _currentQuestionIndex++;
        _currentQuestion = _questions[_currentQuestionIndex];
        _selectedAnswer = '';
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex <= 0) {
      return;
    }
    if (isFirstQuestion) {
      setState(() {
        _currentQuestionIndex--;
        _currentQuestion = _questions[_currentQuestionIndex];
        _selectedAnswer = '';
      });
    }
  }

  String get completedTest {
    final answered = _rightAnswers.length.toString();
    return '$answered out of ${_questions.length} answered';
  }
}
