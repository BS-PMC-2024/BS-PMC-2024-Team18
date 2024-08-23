import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/auth/realsecrets.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';

class QuizAIGeneratedFeedback extends StatefulWidget {
  final List? rightAnswers;
  final List? wrongAnswers;
  final Map? quizData;

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
  List? _rightAnswers;
  List? _wrongAnswers;
  String _feedback = '';
  bool _isLoading = false;
  Map? _quizData;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _wrongAnswers = widget.wrongAnswers;
    _quizData = widget.quizData;
  }

  Future<void> _saveFeedback() async {
    List questions = List.from(_quizData?['questions']);
    try {
      await _firebaseService.saveQuizResults_2(
        widget.quizData?['id'],
        widget.quizData?['name'],
        _rightAnswers?.cast<String>(),
        widget.wrongAnswers?.cast<String>(),
        points,
        questions.cast<Map<dynamic, dynamic>>(),
        _feedback,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz results saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quiz results: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf2b39b),
              Color(0xFFf19b86),
              Color(0xFFf3a292),
              Color(0xFFf8c18e),
              Color(0xFFfcd797),
              Color(0xFFcdd7a7),
              Color(0xFF8fb8aa),
              Color(0xFF73adbb),
              Color(0xFFcc7699),
              Color(0xFF84d9db),
              Color(0xFF85a8cf),
              Color(0xFF8487ac),
              Color(0xFFb7879c),
              Color(0xFF86cfd6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        'AI Generated Feedback',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
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
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the content
              children: [
                const SizedBox(height: 16),
                Text(
                  _quizData!['name'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 16),
                _buildInfoCard(_quizData!),
                const SizedBox(height: 24),
                _buildFeedbackButton(),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_feedback.isNotEmpty)
                  _buildFeedbackSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ElevatedButton _buildFeedbackButton() {
    return ElevatedButton(
      onPressed: _feedback.isEmpty ? _generateFeedback : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(_feedback.isEmpty ? 'Get Feedback' : 'Feedback Received'),
    );
  }

  Column _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback:',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_feedback, style: const TextStyle(fontSize: 16)),
          ),
        ),
        _buildActionButtons(),
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
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StudentHomePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Card _buildInfoCard(Map quizDetails) {
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
                _buildInfoItem(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('MMM d, y').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(quizDetails['createdAt'].toString()))),
                    Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
                _rightAnswers?.length ?? 0, _wrongAnswers?.length ?? 0),
          ],
        ),
      ),
    );
  }

  String get points {
    var points = (_rightAnswers!.length / _quizData?['questionCount']) * 100;
    return points.toStringAsFixed(2);
  }

  Column _buildInfoItem(
      IconData icon, String label, String value, Color color) {
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

  Column _buildProgressBar(int rightAnswers, int wrongAnswers) {
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
            valueColor: const AlwaysStoppedAnimation(Colors.green),
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
              'content':
                  'You are a helpful assistant that writes feedback for completed quizzes.'
            },
            {
              'role': 'user',
              'content':
                  'Generate feedback for the student who completed quiz ${_quizData?["quizName"]} with these correct answers: $_rightAnswers and these incorrect answers: $_wrongAnswers.'
            },
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
