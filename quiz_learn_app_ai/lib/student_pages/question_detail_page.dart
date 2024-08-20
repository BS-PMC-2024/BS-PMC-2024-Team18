import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../auth/realsecrets.dart';
//import '../auth/secerts.dart';
import '../auth/secrets.dart';
class QuestionDetailPage extends StatefulWidget {
  final String questionText;
  final String answer;
  final bool isRight;
  final int index;

  const QuestionDetailPage({
    super.key,
    required this.questionText,
    required this.answer,
    required this.isRight,
    required this.index,
  });

  @override
  QuestionDetailPageState createState() => QuestionDetailPageState();
}

class QuestionDetailPageState extends State<QuestionDetailPage> {
  String _explanation = '';
  bool _isLoading = false;

  Future<void> _getExplanation() async {
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
              'content': 'You are a helpful assistant that explains quiz answers.'
            },
            {
              'role': 'user',
              'content': 'Explain why the following answer to this question is ${widget.isRight ? "correct" : "incorrect"}. Question: ${widget.questionText}. Answer: ${widget.answer}'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _explanation = jsonResponse['choices'][0]['message']['content'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _explanation = 'Failed to get explanation: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _explanation = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${widget.index + 1}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.questionText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'Answer:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.answer,
              style: TextStyle(
                fontSize: 16,
                color: widget.isRight ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  widget.isRight ? Icons.check_circle : Icons.cancel,
                  color: widget.isRight ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isRight ? 'Correct' : 'Incorrect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isRight ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _explanation.isEmpty ? _getExplanation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_explanation.isEmpty ? 'Get Explanation' : 'Explanation Received'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_explanation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _explanation,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}