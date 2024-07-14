import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentStartQuizPage extends StatefulWidget {
  final String quizId;

  const StudentStartQuizPage({super.key, required this.quizId});

  @override
  StudentStartQuizPageState createState() => StudentStartQuizPageState();
}

class StudentStartQuizPageState extends State<StudentStartQuizPage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> _quizData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null){
        final snapshot = await _database
            .ref()
            .child('lecturers')
            .child('quizzes')
            .child(widget.quizId)
            .get();

        if (snapshot.exists) {
          setState(() {
            _quizData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz: ${e.toString()}')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()): SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quizData['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Questions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._buildQuestions(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildQuestions() {
    if (_quizData['questions'] == null) {
      return [const Text('No questions available')];
    }

    return (_quizData['questions'] as List).asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${index + 1}:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const SizedBox(height: 8),
              Text(
                question['question'] ?? 'No question text',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Options:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._buildOptions(question),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildOptions(Map<dynamic, dynamic> question) {
    if (question['options'] == null) {
      return [const Text('No options available', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))];
    }

    return (question['options'] as List).asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4),
        child: Row(
          children: [
            Text(
              '${String.fromCharCode(65 + index)}. ',
              style: const TextStyle(fontSize: 14),
            ),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
