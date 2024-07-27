import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/auth/realsecrets.dart';
import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';

class QuizAIGeneratedFeedback extends StatefulWidget {
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final Map<dynamic, dynamic>? quizData;

  const QuizAIGeneratedFeedback({
    super.key,
    this.rightAnswers,
    this.wrongAnswers,
    this.quizData,
  });

  @override
  QuizAIGeneratedFeedbackState createState() => QuizAIGeneratedFeedbackState();
}

class QuizAIGeneratedFeedbackState extends State<QuizAIGeneratedFeedback> {
  List<String>? _rightAnswers;
  List<String>? _wrongAnswers;
  String _feedback = '';
  bool _isLoading = false;
  Map<dynamic, dynamic>? _quizData;
  final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _wrongAnswers = widget.wrongAnswers;
    _quizData = widget.quizData;
  }

  Future<void> _saveFeedback() async {
    List<Map<dynamic, dynamic>> questions = [];
    questions = List<Map<dynamic, dynamic>>.from(_quizData?['questions']);
    try {
      await _firebaseService.saveQuizResults_2(
        widget.quizData?['id'],
        widget.quizData?['name'],
        _rightAnswers,
        widget.wrongAnswers,
        points,
        questions,
        _feedback
      );
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz results saved successfully')),
      );}
     
    } catch (e) {
       if(mounted){  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz results: ${e.toString()}')),
      );}
    
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    // Call the chat GPT API to generate feedback based on quizScore
    return Scaffold(
    body: BackgroundDecoration(
      child: SafeArea(
        child: Column(
          children: [
             AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: const Text('AI Generated Feedback', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    ),
   
   );
 }
  
  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  _quizData!['name'],
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(_quizData!),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _feedback.isEmpty ? _generateFeedback : null,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_feedback.isEmpty ? 'Get Feedback' : 'Feedback Received'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_feedback.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _feedback,
                    style: const TextStyle(fontSize: 16),
                  ),
                  _buildActionButtons()
                ],
              ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildActionButtons() {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Go Home"),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _saveFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ],
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
                _buildInfoItem(Icons.star, 'Score', points, Colors.amber),
                _buildInfoItem(Icons.calendar_today, 'Date', 
                  DateFormat('MMM d, y').format(DateTime.fromMillisecondsSinceEpoch(
                          int.parse(quizDetails['createdAt'].toString()))), 
                  Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(_rightAnswers?.length ?? 0, _wrongAnswers?.length ?? 0),
          ],
        ),
      ),
    );
  }
  String get points {
    var points = (_rightAnswers!.length / _quizData?['questionCount']) * 100;
    return points.toStringAsFixed(2);
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

  Future<void> _generateFeedback() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = mySecretKey;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that write a feedback for completed quiz.'
            },
            {
              'role': 'user',
              'content': 'Generate feedback for the student that completed quiz ${_quizData?["quizName"]} with this correct answers: $_rightAnswers and this incorrect answers: $_wrongAnswers .'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _feedback = jsonResponse['choices'][0]['message']['content'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _feedback = 'Failed to get feedback: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _feedback = 'Error: $e';
        _isLoading = false;
      });
    }
  }
}