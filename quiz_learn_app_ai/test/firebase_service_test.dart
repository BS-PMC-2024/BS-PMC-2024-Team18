// firebase_service_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'mocks/firebase_service_test.mocks.dart';

 

 //flutter test test/sign_in_test_2.dart to run mock: flutter pub run build_runner build 
 //flutter test test/question_generator_test.dart

@GenerateMocks([DatabaseReference, DataSnapshot, DatabaseEvent, FirebaseAuth, User])
void main() {
  late MockDatabaseReference mockDatabaseReference;
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseService firebaseService;
  late MockUser mockUser;

  setUp(() {
    mockDatabaseReference = MockDatabaseReference();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    firebaseService = FirebaseService(database: mockDatabaseReference, auth: mockFirebaseAuth);

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
  });

  group('FirebaseService', () {
  
test('saveQuiz should update quiz data in the database', () async {
      final quizId = 'test_quiz_id';
      final quizName = 'Test Quiz';
      final questions = [
        {'question': 'Q1', 'answer': 'A1'},
        {'question': 'Q2', 'answer': 'A2'},
      ];
      final description = 'Test Description';

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.update(any)).thenAnswer((_) => Future.value());

      await firebaseService.saveQuiz(quizId, quizName, questions, description);

      verify(mockDatabaseReference.child('lecturers')).called(1);
      verify(mockDatabaseReference.child('test_user_id')).called(1);
      verify(mockDatabaseReference.child('quizzes')).called(1);
      verify(mockDatabaseReference.child(quizId)).called(1);
      verify(mockDatabaseReference.update({
        'name': quizName,
        'questions': questions,
        'description': description,
      })).called(1);
    });

    test('saveQuiz should throw exception when user is not authenticated', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => firebaseService.saveQuiz('quizId', 'quizName', [], 'description'),
        throwsA(isA<Exception>()),
      );
    });
  });


    test('saveQuizToFirebase should save quiz data to the database', () async {
      final quizName = 'Test Quiz';
      final subject = 'Test Subject';
      final questions = [
        {'question': 'Q1', 'answer': 'A1'},
        {'question': 'Q2', 'answer': 'A2'},
      ];

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.push()).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.set(any)).thenAnswer((_) => Future.value());

      await firebaseService.saveQuizToFirebase(quizName, subject, questions);

      verify(mockDatabaseReference.child('lecturers')).called(1);
      verify(mockDatabaseReference.child('test_user_id')).called(1);
      verify(mockDatabaseReference.child('quizzes')).called(1);
      verify(mockDatabaseReference.push()).called(1);
      verify(mockDatabaseReference.set({
        'name': quizName,
        'subject': subject,
        'questions': questions,
        'createdAt': ServerValue.timestamp,
      })).called(1);
    });

    test('saveQuizToFirebase should throw exception when user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => firebaseService.saveQuizToFirebase('Quiz Name', 'Subject', []),
        throwsA(isA<Exception>()),
      );
    });
}