import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_quiz_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/quiz_details_page.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class StudentQuizzesPage extends StatefulWidget {
  const StudentQuizzesPage({super.key});

  @override
  StudentQuizzesPageState createState() => StudentQuizzesPageState();
}

class StudentQuizzesPageState extends State<StudentQuizzesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;
  

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _database
            .child('lecturers')
            .child(user.uid)
            .child('quizzes')
            .get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          _quizzes = data.entries.map((entry) {
            final quiz = entry.value as Map<dynamic, dynamic>;
            return {
              'id': entry.key,
              'name': quiz['name'],
              'subject': quiz['subject'],
              'lecturer': quiz['lecturer'],
              'questionCount': (quiz['questions'] as List).length,
              'pints': quiz['points'],
              'questions': quiz['questions'],
            };
          }).toList();

          _quizzes.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        }
      }
    } catch (e) {
      if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
      );

      }
     
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuiz(String quizId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _database
            .child('lecturers')
            .child(user.uid)
            .child('quizzes')
            .child(quizId)
            .remove();

        setState(() {
          _quizzes.removeWhere((quiz) => quiz['id'] == quizId);
        });
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
        }
       
      }
    } catch (e) {
      if(mounted){
 ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting quiz: ${e.toString()}')),
      );
      }
     
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuizPage()),
          ).then((_) => _loadQuizzes());
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFeb8671), // #eb8671
          Color(0xFFea7059), // #ea7059
          Color(0xFFef7d5d), // #ef7d5d
          Color(0xFFf8a567), // #f8a567
          Color(0xFFfecc63), // #fecc63
          Color(0xFFa7c484), // #a7c484
          Color(0xFF5b9f8d), // #5b9f8d
          Color(0xFF257b8c), // #257b8c
          Color(0xFFad3d75), // #ad3d75
          Color(0xFF1fd1d5), // #1fd1d5
          Color(0xFF2e7cbc), // #2e7cbc
          Color(0xFF3d5488), // #3d5488
          Color(0xFF99497f), // #99497f
          Color(0xFF23b7c1), // #23b7c1
        ],
      ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Quizzes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _quizzes.isEmpty
                          ? Center(
                              child: Text(
                                'No quizzes found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _quizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = _quizzes[index];
                                return _buildQuizCard(quiz);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailsPage(
              quizId: quiz['id'],
              initialQuizName: quiz['name'],
            ),
          ),
        ).then((_) => _loadQuizzes());
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quiz['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(quiz['id']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Subject: ${quiz['subject'] ?? 'Not specified'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${quiz['questionCount']} questions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Created on ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(quiz['createdAt']))}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showDeleteConfirmation(String quizId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quiz'),
          content: const Text('Are you sure you want to delete this quiz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteQuiz(quizId);
              },
            ),
          ],
        );
      },
    );
  }
}
