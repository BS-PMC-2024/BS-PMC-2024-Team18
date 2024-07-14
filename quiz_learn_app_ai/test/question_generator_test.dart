// test/question_generator_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/question_generator.dart';
import 'mocks/question_generator.mocks.dart';

// This annotation is used to generate the mocks for the http.Client
@GenerateMocks([http.Client])
void main() {
  group('QuestionGenerator', () {
    final mockClient = MockClient();
    final questionGenerator = QuestionGenerator(client: mockClient);
    const testText = 'Some test text for generating questions';

     test('should return a list of questions on successful API call', () async {
      // Mock the HTTP response
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
            'choices': [
              {
                'message': {
                  'content': '''```json
                  {
                    "description": "This is a quiz about general knowledge.",
                    "questions": [
                      {
                        "question": "What is the capital of France?",
                        "correct_answer": "Paris",
                        "incorrect_answers": ["Lyon", "Marseille", "Nice"]
                      },
                      {
                        "question": "What is the largest ocean on Earth?",
                        "correct_answer": "Pacific Ocean",
                        "incorrect_answers": ["Atlantic Ocean", "Indian Ocean", "Arctic Ocean"]
                      }
                    ]
                  }```'''
                }
              }
            ]
          }), 200));

      final result = await questionGenerator.generateQuestions(testText);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 3); // 2 questions + 1 description
      
      // Check the questions
      for (int i = 0; i < 2; i++) {
        expect(result[i]['question'], isA<String>());
        expect(result[i]['correct_answer'], isA<String>());
        expect(result[i]['incorrect_answers'], isA<List>());
        expect(result[i]['incorrect_answers'].length, 3);
      }

      // Check the description
      expect(result[2]['description'], isA<String>());
      expect(result[2]['description'], 'This is a quiz about general knowledge.');
    });
    
    test('should throw an exception on API error', () async {
      // Mock the HTTP response with an error
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      // Call the method and verify that it throws an exception
      expect(
        () async => await questionGenerator.generateQuestions(testText),
        throwsException,
      );
    });

    test('should throw FormatException on invalid JSON response', () async {
      // Mock the HTTP response with invalid JSON
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
            'choices': [
              {
                'message': {
                  'content': '''```json
                  { "invalid": "json" }```'''
                }
              }
            ]
          }), 200));

      // Call the method and verify that it throws a FormatException
      expect(
        () async => await questionGenerator.generateQuestions(testText),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
