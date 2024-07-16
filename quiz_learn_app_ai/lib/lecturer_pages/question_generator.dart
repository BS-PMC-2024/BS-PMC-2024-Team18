// lib/lecturer_pages/question_generator.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../auth/secerts.dart';

class QuestionGenerator {
  final String apiKey = mySecretKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final http.Client client;

  QuestionGenerator({http.Client? client}) : client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> generateQuestions(String text) async {
    final response = await client.post(
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
            'content': 'You are a helpful assistant that generates multiple-choice questions and a quiz description.'
          },
          {
            'role': 'user',
            'content': 'Generate 5 multiple-choice questions and a short description about the following questions. Each question should have one correct answer and three incorrect answers. Format the output as a JSON object with a "description" field and a "questions" field containing an array of question objects. Text: $text'
          }
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      var content = jsonResponse['choices'][0]['message']['content'];
      content = content.replaceAll('```json', '').replaceAll('```', '').trim();

      try {
        // final List<dynamic> questions = jsonDecode(content);
        // return questions.map((q) => Map<String, dynamic>.from(q)).toList();
         final Map<String, dynamic> quiz = jsonDecode(content);
         final List<dynamic> questions = quiz['questions'];
         final List<Map<String, dynamic>> result = questions.map((q) => Map<String, dynamic>.from(q)).toList();
         result.add({'description': quiz['description']});

        return result;
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing JSON: $content');
        }
        if (kDebugMode) {
          print('Error details: $e');
        }
        throw FormatException('Failed to parse questions: $e');
      }
    } else {
      if (kDebugMode) {
        print('API Error: ${response.body}');
      }
      throw Exception('Failed to generate questions: ${response.statusCode}');
    }
  }
}
