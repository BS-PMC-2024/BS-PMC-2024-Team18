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

  group('FirebaseService saveQuizToFirebase loadQuizDetails', () {
    test('loadQuizDetails returns quiz data when it exists', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({'name': 'Test Quiz', 'questions': []});
      
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);

      final result = await firebaseService.loadQuizDetails('test_quiz_id');

      expect(result, isNotNull);
      expect(result!['name'], 'Test Quiz');
    });

    test('loadQuizDetails returns null when quiz does not exist', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockSnapshot.exists).thenReturn(false);
      
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);

      final result = await firebaseService.loadQuizDetails('non_existent_quiz_id');

      expect(result, isNull);
    });

    test('saveQuiz updates quiz data correctly', () async {
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.update(any)).thenAnswer((_) async => {});

      await firebaseService.updateQuiz(
        'test_quiz_id',
        'Updated Quiz Name',
        [{'question': 'Test Question'}],
        'Test Description'
      );

      verify(mockDatabaseReference.update({
        'name': 'Updated Quiz Name',
        'questions': [
          {'question': 'Test Question', 'description': 'Test Description'}
        ],
      })).called(1);
    });

    test('saveQuizToFirebase creates new quiz correctly', () async {
      final mockPushRef = MockDatabaseReference();
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.push()).thenReturn(mockPushRef);
      when(mockPushRef.set(any)).thenAnswer((_) async => {});

      await firebaseService.saveQuizToFirebase(
        'New Quiz',
        'Math',
        [{'question': 'New Question'}]
      );

      verify(mockPushRef.set({
        'name': 'New Quiz',
        'subject': 'Math',
        'questions': [{'question': 'New Question'}],
        'createdAt': ServerValue.timestamp,
      })).called(1);
    });

    test('saveQuizToFirebase throws exception when user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => firebaseService.saveQuizToFirebase('New Quiz', 'Math', []),
        throwsA(isA<Exception>())
      );
    });
  });


group('loadUserData', () {
    test('returns user data when user is logged in', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      
      when(mockUser.email).thenReturn('test@example.com');
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.once()).thenAnswer((_) async => mockEvent);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn({'userType': 'student'});

      // Act
      final result = await firebaseService.loadUserData();

      // Assert
      expect(result, {
        'email': 'test@example.com',
        'userType': 'student',
      });
      verify(mockDatabaseReference.child('users')).called(1);
      verify(mockDatabaseReference.child('test_user_id')).called(1);
    });

    test('throws exception when user is not logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => firebaseService.loadUserData(), throwsA(isA<Exception>()));
    });

    test('returns null userType when it does not exist in database', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      
      when(mockUser.email).thenReturn('test@example.com');
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.once()).thenAnswer((_) async => mockEvent);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn({});

      // Act
      final result = await firebaseService.loadUserData();

      // Assert
      expect(result, {
        'email': 'test@example.com',
        'userType': null,
      });
    });
  });


  group('FirebaseService saveProfile loadUserData_2', () {
    test('loadUserData_2 returns correct user data when user is logged in', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      final mockUserData = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '1234567890',
        'workplace': 'Test University',
        'qualifications': 'PhD',
        'bio': 'Test bio',
        'courses': ['Math', 'Physics']
      };

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.once()).thenAnswer((_) async => mockEvent);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn(mockUserData);

      // Act
      final result = await firebaseService.loadUserData_2();

      // Assert
      expect(result, equals(mockUserData));
      verify(mockDatabaseReference.child('lecturers')).called(1);
      verify(mockDatabaseReference.child('test_user_id')).called(1);
    });

    test('loadUserData_2 throws exception when user is not logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => firebaseService.loadUserData_2(), throwsA(isA<Exception>()));
    });

    test('saveProfile updates profile data correctly', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      final existingData = {'existingField': 'existingValue'};
      final newProfileData = {'name': 'John Doe', 'email': 'john@example.com'};

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.once()).thenAnswer((_) async => mockEvent);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn(existingData);
      when(mockDatabaseReference.update(any)).thenAnswer((_) async => {});

      // Act
      await firebaseService.saveProfile(newProfileData);

      // Assert
      verify(mockDatabaseReference.child('lecturers')).called(2);
      verify(mockDatabaseReference.child('test_user_id')).called(2);
      verify(mockDatabaseReference.update({
        'existingField': 'existingValue',
        'name': 'John Doe',
        'email': 'john@example.com'
      })).called(1);
    });

    test('saveProfile throws exception when user is not logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => firebaseService.saveProfile({}), throwsA(isA<Exception>()));
    });
  });
  

  group('FirebaseService loadQuizzes', () {
    test('loadQuizzes returns correct list of quizzes', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();
      final mockQuizData = {
        'quiz1': {
          'name': 'Quiz 1',
          'subject': 'Math',
          'createdAt': 1000,
          'questions': [{'q1': 'Question 1'}, {'q2': 'Question 2'}]
        },
        'quiz2': {
          'name': 'Quiz 2',
          'subject': 'Science',
          'createdAt': 2000,
          'questions': [{'q1': 'Question 1'}]
        }
      };

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn(mockQuizData);

      // Act
      final result = await firebaseService.loadQuizzes();

      // Assert
      expect(result.length, 2);
      expect(result[0]['name'], 'Quiz 2');  // Sorted by createdAt descending
      expect(result[1]['name'], 'Quiz 1');
      expect(result[0]['questionCount'], 1);
      expect(result[1]['questionCount'], 2);
    });

    test('loadQuizzes returns empty list when no quizzes exist', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();

      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      // Act
      final result = await firebaseService.loadQuizzes();

      // Assert
      expect(result, isEmpty);
    });


    test('deleteQuiz removes quiz successfully', () async {
      // Arrange
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.remove()).thenAnswer((_) async => {});

      // Act
      await firebaseService.deleteQuiz('quiz1');

      // Assert
      verify(mockDatabaseReference.child('lecturers')).called(1);
      verify(mockDatabaseReference.child('test_user_id')).called(1);
      verify(mockDatabaseReference.child('quizzes')).called(1);
      verify(mockDatabaseReference.child('quiz1')).called(1);
      verify(mockDatabaseReference.remove()).called(1);
    });

    test('deleteQuiz throws exception when user is not logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      await expectLater(firebaseService.deleteQuiz('quiz1'), throwsA(isA<Exception>()));
    });
  });


 group('FirebaseService - loadAllQuizzes', () {
    test('returns correct list of quizzes when data exists', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('lecturers')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        'lecturer1': {
          'name': 'John Doe',
          'quizzes': {
            'quiz1': {
              'name': 'Math Quiz',
              'subject': 'Math',
              'createdAt': 1000,
              'questions': ['q1', 'q2']
            },
            'quiz2': {
              'name': 'Science Quiz',
              'subject': 'Science',
              'createdAt': 2000,
              'questions': ['q1']
            }
          }
        },
        'lecturer2': {
          'name': 'Jane Smith',
          'quizzes': {
            'quiz3': {
              'name': 'History Quiz',
              'subject': 'History',
              'createdAt': 3000,
              'questions': ['q1', 'q2', 'q3']
            }
          }
        }
      });

      // Act
      final result = await firebaseService.loadAllQuizzes();

      // Assert
      expect(result.length, 3);
      expect(result[0]['name'], 'History Quiz');
      expect(result[1]['name'], 'Science Quiz');
      expect(result[2]['name'], 'Math Quiz');
      expect(result[0]['lecturer'], 'Jane Smith');
      expect(result[1]['lecturer'], 'John Doe');
      expect(result[2]['questionCount'], 2);
    });

    test('returns empty list when no data exists', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('lecturers')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      // Act
      final result = await firebaseService.loadAllQuizzes();

      // Assert
      expect(result, isEmpty);
    });

    test('throws exception when database error occurs', () async {
      // Arrange
      when(mockDatabaseReference.child('lecturers')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => firebaseService.loadAllQuizzes(), throwsException);
    });
  });
  

   group('FirebaseService - filterQuizzes', () {
    final allQuizzes = [
      {
        'name': 'Math Quiz',
        'subject': 'Math',
        'lecturer': 'John Doe',
        'createdAt': '1625097600000', // July 1, 2021
      },
      {
        'name': 'Science Quiz',
        'subject': 'Science',
        'lecturer': 'Jane Smith',
        'createdAt': '1627776000000', // August 1, 2021
      },
      {
        'name': 'History Quiz',
        'subject': 'History',
        'lecturer': 'Bob Johnson',
        'createdAt': '1630454400000', // September 1, 2021
      },
    ];

    test('filters quizzes correctly based on search term', () {
      final result = firebaseService.filterQuizzes(allQuizzes, 'math', 'All', 'All', null, null);
      expect(result.length, 1);
      expect(result[0]['name'], 'Math Quiz');
    });

    test('filters quizzes correctly based on lecturer', () {
      final result = firebaseService.filterQuizzes(allQuizzes, '', 'Jane Smith', 'All', null, null);
      expect(result.length, 1);
      expect(result[0]['name'], 'Science Quiz');
    });

    test('filters quizzes correctly based on subject', () {
      final result = firebaseService.filterQuizzes(allQuizzes, '', 'All', 'History', null, null);
      expect(result.length, 1);
      expect(result[0]['name'], 'History Quiz');
    });

    test('filters quizzes correctly based on date range', () {
      final startDate = DateTime(2021, 7, 15);
      final endDate = DateTime(2021, 8, 15);
      final result = firebaseService.filterQuizzes(allQuizzes, '', 'All', 'All', startDate, endDate);
      expect(result.length, 1);
      expect(result[0]['name'], 'Science Quiz');
    });

    test('returns all quizzes when no filters are applied', () {
      final result = firebaseService.filterQuizzes(allQuizzes, '', 'All', 'All', null, null);
      expect(result.length, 3);
    });
  });


   group('FirebaseService - loadUsers', () {
    test('loads users correctly when data exists', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('users')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.value).thenReturn({
        'user1': {'email': 'user1@example.com', 'userType': 'Student'},
        'user2': {'email': 'user2@example.com', 'userType': 'Lecturer'},
      });

      final result = await firebaseService.loadUsers();

      expect(result.length, 2);
      expect(result[0].id, 'user1');
      expect(result[0].email, 'user1@example.com');
      expect(result[0].userType, 'Student');
      expect(result[1].id, 'user2');
      expect(result[1].email, 'user2@example.com');
      expect(result[1].userType, 'Lecturer');
    });

    test('returns empty list when no users exist', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('users')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.value).thenReturn(null);

      final result = await firebaseService.loadUsers();

      expect(result, isEmpty);
    });

    test('throws exception when database error occurs', () async {
      when(mockDatabaseReference.child('users')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenThrow(Exception('Database error'));

      expect(() => firebaseService.loadUsers(), throwsException);
    });
  });

   group('FirebaseService loadCompletedQuizzes,loadQuizDetailsForStudents,loadQuizResults,saveQuizResults', () {
    test('saveQuizResults should save quiz results successfully', () async {
      final mockPush = MockDatabaseReference();
      when(mockDatabaseReference.child('students')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('test_user_id')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('quizResults')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.push()).thenReturn(mockPush);
      when(mockPush.set(any)).thenAnswer((_) => Future.value());

      await firebaseService.saveQuizResults(
        'quiz_id',
        'Quiz Name',
        ['Right 1', 'Right 2'],
        ['Wrong 1'],
        '10',
        [{'question': 'Q1', 'answer': 'A1'}],
      );

      verify(mockPush.set(any)).called(1);
    });

    test('loadQuizResults should return quiz results', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('students')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('test_user_id')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('quizResults')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) => Future.value(mockSnapshot));
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        'quiz1': {
          'quizName': 'Quiz 1',
          'rightAnswers': ['Right 1'],
          'wrongAnswers': ['Wrong 1'],
          'points': '10',
          'date': '2024-07-16',
        }
      });

      final results = await firebaseService.loadQuizResults();

      expect(results.length, 1);
      expect(results[0]['quizId'], 'quiz1');
      expect(results[0]['quizName'], 'Quiz 1');
    });

    test('loadQuizDetailsForStudents should return quiz details', () async {
      final mockSnapshot = MockDataSnapshot();
      when(mockDatabaseReference.child('students')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('test_user_id')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('quizResults')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child('quiz_id')).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) => Future.value(mockSnapshot));
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        'quizName': 'Quiz 1',
        'points': '10',
        'date': '2024-07-16',
        'rightAnswers': ['Right 1'],
        'wrongAnswers': ['Wrong 1'],
        'questions': [{'question': 'Q1', 'answer': 'A1'}],
      });

      final result = await firebaseService.loadQuizDetailsForStudents('quiz_id');

      expect(result, isNotNull);
      expect(result!['quizId'], 'quiz_id');
      expect(result['quizName'], 'Quiz 1');
    });

 
  });
}