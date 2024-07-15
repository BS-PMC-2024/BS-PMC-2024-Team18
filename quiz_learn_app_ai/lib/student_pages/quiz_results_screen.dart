import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'quiz_detail_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  QuizResultsScreenState createState() => QuizResultsScreenState();
}

class QuizResultsScreenState extends State<QuizResultsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _firebaseService.loadQuizResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quiz results found.'));
          }

          final results = snapshot.data!;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final rightAnswers = result['rightAnswers'] is List ? result['rightAnswers'] : [];
              final wrongAnswers = result['wrongAnswers'] is List ? result['wrongAnswers'] : [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text(result['quizName']),
                  subtitle: Text('Score: ${result['points']} points\nDate: ${result['date']}'),
                  trailing: Icon(
                    rightAnswers.length > wrongAnswers.length
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: rightAnswers.length > wrongAnswers.length
                        ? Colors.green
                        : Colors.red,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetailScreen(quizId: result['quizId']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
