import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/student_pages/question_detail_page.dart';

class QuizDetailScreen extends StatelessWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Quiz Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          final rightAnswers = List<String>.from(quizDetails['rightAnswers'] ?? []);
          final wrongAnswers = List<String>.from(quizDetails['wrongAnswers'] ?? []);

          final List<dynamic> questions = questionsData is List
              ? questionsData
              : (questionsData as Map).values.toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quizDetails['quizName'],
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(quizDetails),
                      const SizedBox(height: 24),
                      const Text('Questions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final question = questions[index];
                    final questionText = question['question'] ?? 'No question text available.';
                    final answer = question['answer'] ?? 'No answer available.';
                    final isRight = rightAnswers.contains(answer);
                    final isWrong = wrongAnswers.contains(answer);

                    return _buildQuestionCard(questionText, answer, isRight, isWrong, index ,context);
                  },
                  childCount: questions.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Map<dynamic, dynamic> quizDetails) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.star, 'Score', '${quizDetails['points']}', Colors.amber),
                _buildInfoItem(Icons.calendar_today, 'Date', 
                  DateFormat('MMM d, y').format(DateTime.parse(quizDetails['date'])), 
                  Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(quizDetails['rightAnswers']?.length ?? 0, quizDetails['wrongAnswers']?.length ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressBar(int rightAnswers, int wrongAnswers) {
    final total = rightAnswers + wrongAnswers;
    final rightPercentage = total > 0 ? (rightAnswers / total).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: rightPercentage,
            backgroundColor: Colors.red.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Correct: $rightAnswers', style: const TextStyle(color: Colors.green)),
            Text('Incorrect: $wrongAnswers', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String questionText, String answer, bool isRight, bool isWrong, int index, BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
      ),
      title: Text(
        questionText,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isRight ? Icons.check_circle : Icons.cancel,
                    color: isRight ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Answer: $answer',
                      style: TextStyle(
                        fontSize: 16,
                        color: isRight ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionDetailPage(
                        questionText: questionText,
                        answer: answer,
                        isRight: isRight,
                        index: index,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}