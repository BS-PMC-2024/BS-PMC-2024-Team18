import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/quiz_details_page.dart';

class MyQuizzesPage extends StatefulWidget {
  const MyQuizzesPage({super.key});

  @override
  MyQuizzesPageState createState() => MyQuizzesPageState();
}

class MyQuizzesPageState extends State<MyQuizzesPage> {
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
              'createdAt': quiz['createdAt'],
              'questionCount': (quiz['questions'] as List).length,
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
      appBar: AppBar(
        title: const Text('My Quizzes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? const Center(child: Text('No quizzes found'))
              : ListView.builder(
                  itemCount: _quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    return ListTile(
                      title: Text(quiz['name']),
                      subtitle: Text(
                          '${quiz['questionCount']} questions • Created on ${DateTime.fromMillisecondsSinceEpoch(quiz['createdAt']).toString().split(' ')[0]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(quiz['id']),
                      ),
                     onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizDetailsPage(
        quizId: quiz['id'],
        initialQuizName: quiz['name'],
      ),
    ),
  ).then((_) => _loadQuizzes()); // Reload quizzes when returning from details page
},
                    );
                  },
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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