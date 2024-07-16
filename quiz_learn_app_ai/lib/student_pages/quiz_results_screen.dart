import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'quiz_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  _resultsFuture = _firebaseService.loadQuizResults().then((results) {
    // Sort the results by date in descending order
    results.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    return results;
  });
}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Quiz History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                final rightAnswers = result['rightAnswers'] is List ? result['rightAnswers'] : [];
                final wrongAnswers = result['wrongAnswers'] is List ? result['wrongAnswers'] : [];

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizDetailScreen(quizId: result['quizId']),
                              ),
                            );
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
                                        result['quizName'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    _buildScoreIndicator(rightAnswers.length, wrongAnswers.length),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${DateFormat('MMMM d, y h:mm a').format(DateTime.parse(result['date']))}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 12),
                                _buildProgressBar(rightAnswers.length, wrongAnswers.length),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreIndicator(int rightAnswers, int wrongAnswers) {
    final total = rightAnswers + wrongAnswers;
    final percentage = total > 0 ? (rightAnswers / total * 100).round() : 0;
    final color = percentage > 70 ? Colors.green : (percentage > 40 ? Colors.orange : Colors.red);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

 Widget _buildProgressBar(int rightAnswers, int wrongAnswers) {
  final total = rightAnswers + wrongAnswers;
  final rightPercentage = total > 0 ? (rightAnswers / total).toDouble() : 0.0;

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: rightPercentage,
      backgroundColor: Colors.red.withOpacity(0.2),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
      minHeight: 10,
    ),
  );
}
}