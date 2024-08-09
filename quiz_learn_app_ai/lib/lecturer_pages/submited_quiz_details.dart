
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
//import 'package:quiz_learn_app_ai/student_pages/question_detail_page.dart';

class SubmitedQuizDetail extends StatefulWidget {
  final Map<String, dynamic> student;
  const SubmitedQuizDetail({
    super.key,
    required this.student,
  });

  @override
  SubmitedQuizDetailState createState() => SubmitedQuizDetailState();
}

class SubmitedQuizDetailState extends State<SubmitedQuizDetail> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isFeedbackVisible = false;

  late final Map<String, dynamic> student;

  @override
  void initState() {
    super.initState();
    student = widget.student;
  }

  void _showFeedbackField() {
    setState(() {
      if (_isFeedbackVisible) {
        _isFeedbackVisible = false;
      } else {
        _isFeedbackVisible = true;
      }
    });
  }

  void _saveFeedback() {
    final feedback = _feedbackController.text;
    final FirebaseService firebaseService = FirebaseService();
    firebaseService.saveQuizResults_3(feedback, student);
    if (kDebugMode) {
      print('Feedback saved: $feedback');
    }

    // Clear the text field and hide it
    _feedbackController.clear();
    setState(() {
      _isFeedbackVisible = false;
    });
  }

  List<String> castToStringList(List<Object?> original) {
    return original
        .whereType<String>()
        .map((item) => item)
        .toList();
  }

  Map<String, dynamic> convertListToMap(List<Object?> list) {
    return Map.fromEntries(list.asMap().entries.map(
          (entry) => MapEntry(entry.key.toString(), entry.value as dynamic),
        ));
  }

  @override
  Widget build(BuildContext context) {
    //final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Submission Details',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] ?? 'Student',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(student),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isFeedbackVisible) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _feedbackController,
                              decoration: const InputDecoration(
                                labelText: 'Enter feedback',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveFeedback,
                            child: const Text('Save Feedback'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: _showFeedbackField,
                      backgroundColor: const Color.fromARGB(255, 127, 101, 171),
                      child: const Icon(Icons.feedback),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Questions',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
            ),
          ),
         SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final questions = student['questions'] ?? [];
      final rightAnswers = student['rightAnswers'] ?? [];
      final wrongAnswers = student['wrongAnswers'] ?? [];

      if (index >= questions.length) {
        return const SizedBox.shrink(); // Return an empty widget if index is out of range
      }

      final question = questions[index];
      final questionText = question['question'] ?? 'No question text available.';
      final answer = question['answer'] ?? 'No answer available.';
      final isRight = rightAnswers.contains(answer);
      final isWrong = wrongAnswers.contains(answer);
      final rightAnswer = castToStringList(question['options'])
          .firstWhere((option) => rightAnswers.contains(option), orElse: () => 'No correct answer found.');
      return _buildQuestionCard(
        questionText, answer, isRight, isWrong, index, context, rightAnswer,);
    },
    childCount: student['questionCount'] ?? 0,
  ),
),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text('AI Feedback',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 16),
                  Text(
                    student['feedback'] ?? 'No feedback available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoCard(Map<String, dynamic> student) {
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
              _buildInfoItem(
                  Icons.star, 'Score', '${student['points']}', Colors.amber),
              _buildInfoItem(
                  Icons.calendar_today,
                  'Date',
                  DateFormat('MMM d, y')
                      .format(DateTime.parse(student['date'])),
                  Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(student['rightAnswers']?.length ?? 0,
              student['wrongAnswers']?.length ?? 0),
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
      Text(value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget _buildProgressBar(int rightAnswers, int wrongAnswers) {
  final total = rightAnswers + wrongAnswers;
  final rightPercentage = total > 0 ? (rightAnswers / total).toDouble() : 0.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Performance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          Text('Correct: $rightAnswers',
              style: const TextStyle(color: Colors.green)),
          Text('Incorrect: $wrongAnswers',
              style: const TextStyle(color: Colors.red)),
        ],
      ),
    ],
  );
}

Widget _buildQuestionCard(String questionText, String answer, bool isRight,
    bool isWrong, int index, BuildContext context, String rightAnswer) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child:
            Text('${index + 1}', style: const TextStyle(color: Colors.white)),
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
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Answer: $answer',
                          style: TextStyle(
                            fontSize: 16,
                            color: isRight ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Correct Answer: $rightAnswer',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
