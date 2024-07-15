import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class QuizDetailScreen extends StatelessWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
      ),
      body: FutureBuilder<Map<dynamic, dynamic>?>(
        future: firebaseService.loadQuizDetailsForStudents(quizId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Quiz not found.'));
          }

          final quizDetails = snapshot.data!;
          final questionsData = quizDetails['questions'] ?? [];

          // Ensure questionsData is a list
          final List<dynamic> questions = questionsData is List
              ? questionsData
              : (questionsData as Map).values.toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quizDetails['quizName'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Score: ${quizDetails['points']}'),
                const SizedBox(height: 10),
                Text('Date: ${quizDetails['date']}'),
                const SizedBox(height: 20),
                const Text('Questions:', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(question['question'] ?? 'No question text available.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
