import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_quiz_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/quiz_details_page.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart'; // Add this import for date formatting

class MyQuizzesPage extends StatefulWidget {
  const MyQuizzesPage({super.key});

  @override
  MyQuizzesPageState createState() => MyQuizzesPageState();
}

class MyQuizzesPageState extends State<MyQuizzesPage> {
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;
     final FirebaseService _firebaseService = FirebaseService();

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
      _quizzes = await _firebaseService.loadQuizzes();
    } catch (e) {
      if (mounted) {
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
      await _firebaseService.deleteQuiz(quizId);
      
      setState(() {
        _quizzes.removeWhere((quiz) => quiz['id'] == quizId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[400]!],
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
              '${quiz['questionCount'] - 1} questions',
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
