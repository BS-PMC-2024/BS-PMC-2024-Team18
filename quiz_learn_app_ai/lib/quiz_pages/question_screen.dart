import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';

class QuestionScreen extends StatefulWidget {
  final String quizId;
  final String quizName;
  const QuestionScreen(
      {super.key, required this.quizId, required this.quizName});

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late TextEditingController _quizNameController;
  //late TextEditingController _descriptionController;
  List<Map<dynamic, dynamic>> _questions = [];
  Map<dynamic, dynamic> _quizData = {};
  List<Map<dynamic, dynamic>> _allQuizzes = [];
  bool _isLoading = true;
  bool _isCompleted = false;
  String _quizId = '';

  @override
  void initState() {
    super.initState();
    _quizNameController = TextEditingController(text: widget.quizName);
    //_descriptionController = TextEditingController();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _database.child('lecturers').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _allQuizzes = [];
        data.forEach((lecturerId, lecturerData) {
          if (lecturerData['quizzes'] != null) {
            final quizzes = lecturerData['quizzes'] as Map<dynamic, dynamic>;
            quizzes.forEach((quizId, quizData) {
              _allQuizzes.add({
                'id': quizId,
                'name': quizData['name'],
                'subject': quizData['subject'],
                'createdAt': quizData['createdAt'],
                'questions': quizData['questions'],
                'questionCount': (quizData['questions'] as List).length,
                'lecturer': lecturerData['name'] ?? 'Unknown Lecturer',
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final List<Map<dynamic, dynamic>> question =
    //     List<Map<dynamic, dynamic>>.from(_questions);
    return Scaffold(
      body: BackgroundDecoration(
        child: Center(
          child: Column(
            children: [
              if (_isLoading)
                const Expanded(
                  child: CircularProgressIndicator(),
                ),
              if (!_isLoading)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(_questions[0].toString()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
