// firebase_service.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_user_management_page.dart';

class FirebaseService {
  final DatabaseReference _database;
  final FirebaseAuth _auth;

  FirebaseService({DatabaseReference? database , FirebaseAuth? auth})
      : _database = database ?? FirebaseDatabase.instance.ref(),   _auth = auth ?? FirebaseAuth.instance;




 Future<String?> getCurrentLecturerId() async {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

Future<List<Map<String, dynamic>>> loadLecturerQuizStatistics(String lecturerId) async {
  try {
    
    // Fetch all students
    final studentsSnapshot = await _database.child('students').get();
    List<Map<String, dynamic>> quizStatistics = [];

    if (studentsSnapshot.exists) {
      final studentsData = studentsSnapshot.value as Map<dynamic, dynamic>;
      Map<String, Map<String, dynamic>> quizDataMap = {};

      // Iterate over each student
      for (var studentEntry in studentsData.entries) {
        final student = studentEntry.value as Map<dynamic, dynamic>;
        final quizResults = student['quizResults'] as Map<dynamic, dynamic>?;

        if (quizResults != null) {
          // Iterate over each quiz result for the student
          for (var quizResultEntry in quizResults.entries) {
            final quizResult = quizResultEntry.value as Map<dynamic, dynamic>;
            final quizId = quizResult['quizId'];

            double points = double.parse(quizResult['points']); // Use double.parse

            if (quizDataMap.containsKey(quizId)) {
              // Update existing quiz data
              quizDataMap[quizId]!['totalAttempts'] += 1;
              quizDataMap[quizId]!['totalScore'] += points;
              quizDataMap[quizId]!['highestScore'] = 
                  max<double>(quizDataMap[quizId]!['highestScore'], points);
              quizDataMap[quizId]!['lowestScore'] = 
                  min<double>(quizDataMap[quizId]!['lowestScore'], points);
            } else {
              // Initialize new quiz data
              quizDataMap[quizId] = {
                'quizName': quizResult['quizName'],
                'totalAttempts': 1,
                'totalScore': points,
                'highestScore': points,
                'lowestScore': points,
              };
            }
          }
        }
      }

      // Calculate average scores and prepare final statistics list
      quizDataMap.forEach((quizId, data) {
        final totalAttempts = data['totalAttempts'];
        final averageScore = totalAttempts > 0 ? data['totalScore'] / totalAttempts : 0.0;

        quizStatistics.add({
          'quizId': quizId,
          'quizName': data['quizName'],
          'totalAttempts': totalAttempts,
          'averageScore': averageScore,
          'highestScore': data['highestScore'],
          'lowestScore': data['lowestScore'],
        });
      });
    }

    return quizStatistics;
  } catch (e) {
    throw Exception('Error loading quiz statistics: ${e.toString()}');
  }
}

  Future<List<Map<String, dynamic>>> loadComplianceReports() async { 
    try {
      final snapshot = await _database.child('complianceReports').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          return {
            'id': entry.key,
            'reportDetails': entry.value['reportDetails'],
            'complianceStandards': entry.value['complianceStandards'],
            'auditDate': entry.value['auditDate'],
            'userConsentStatus': entry.value['userConsentStatus'],
            'privacySettings': entry.value['privacySettings'],
          };
        }).toList();
      }
    } catch (e) {
      throw Exception('Error loading compliance reports: $e');
    }
    return [];
  }

  Future<void> createComplianceReport(Map<String, dynamic> reportData) async { 
    try {
      await _database.child('complianceReports').push().set(reportData);
    } catch (e) {
      throw Exception('Error creating compliance report: $e');
    }
  }

  Future<void> deleteComplianceReport(String reportId) async {
    try {
      await _database.child('complianceReports').child(reportId).remove();
    } catch (e) {
      throw Exception('Error deleting compliance report: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadPerfomedQuizUsers(
      String quizId) async {
    try {
      //final User? user = _auth.currentUser;
      final snapshot = await _database.child('students').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> students = [];

        data.forEach((key, value) {
          final student = value as Map<dynamic, dynamic>;
          student['userId'] = key;
          final quizResults = student['quizResults'] as Map<dynamic, dynamic>?;
          if (quizResults != null) {
            quizResults.forEach((quizKey, quizValue) {
              final quizResult = quizValue as Map<dynamic, dynamic>;
              if (quizResult['quizId'] == quizId) {
                students.add({
                  'userId': student['userId'],
                  'email': student['email'],
                  'quizResultId': quizKey,
                  'name': student['name'],
                  'quizId': quizId,
                  'quizName': quizResult['quizName'],
                  'points': quizResult['points'],
                  'date': quizResult['date'],
                  'questionCount': quizResult['questions'].length,
                  'questions': quizResult['questions'],
                  'rightAnswers': quizResult['rightAnswers'],
                  'wrongAnswers': quizResult['wrongAnswers'],
                  'feedback': quizResult['feedback'] ?? '',
                });
              }
            });
          }
        });

        return students;
      }
      return [];
    } catch (e) {
      throw Exception('Error loading students: ${e.toString()}');
    }
  }



Future<Map<dynamic, dynamic>?> loadQuizDetails(String quizId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _database
          .child('lecturers')
          .child(user.uid)
          .child('quizzes')
          .child(quizId)
          .get();

      if (snapshot.exists) {
        return snapshot.value as Map<dynamic, dynamic>;
      }
    }
    return null;
  }

Future<void> updateQuiz(String quizId, String quizName, List<Map<dynamic, dynamic>> questions, String description, String startTime, String endTime) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    // Update the last question with the description
    if (questions.isNotEmpty) {
      questions.last['description'] = description;
    }

    await _database
        .child('lecturers')
        .child(user.uid)
        .child('quizzes')
        .child(quizId)
        .update({
      'name': quizName,
      'questions': questions,
      'startTime': startTime,
      'endTime': endTime
    });
  } else {
    throw Exception('User not authenticated');
  }
}



   Future<void> saveQuizToFirebase(String quizName, String subject, List<Map<dynamic, dynamic>> questions) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final newQuizRef = _database.child('lecturers').child(user.uid).child('quizzes').push();
      await newQuizRef.set({
        'name': quizName,
        'subject': subject,
        'questions': questions,
        'createdAt': ServerValue.timestamp,
      });
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<Map<String, dynamic>> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent event = await _database.child('users').child(user.uid).once();
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
      
      return {
        'email': user.email,
        'userType': userData?['userType'],
      };
    }
    throw Exception('User not logged in');
  }


  Future<Map<String, dynamic>> loadUserData_2() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent event = await _database.child('lecturers').child(user.uid).once();
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
      
      return {
        'name': userData?['name'] ?? '',
        'email': userData?['email'] ?? '',
        'phone': userData?['phone'] ?? '',
        'workplace': userData?['workplace'] ?? '',
        'qualifications': userData?['qualifications'] ?? '',
        'bio': userData?['bio'] ?? '',
        'courses': List<String>.from(userData?['courses'] ?? []),
      };
    }
    throw Exception('User not logged in');
  }

  Future<void> saveProfile(Map<String, dynamic> profileData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // First, get the current data
        DatabaseEvent event = await _database.child('lecturers').child(user.uid).once();
        Map<String, dynamic> currentData = {};
        if (event.snapshot.exists) {
          currentData = Map<String, dynamic>.from(event.snapshot.value as Map);
        }

        // Update only the fields managed in the profile
        currentData.addAll(profileData);

        // Save the updated data
        await _database.child('lecturers').child(user.uid).update(currentData);
      } catch (e) {
        throw Exception('Error saving profile: ${e.toString()}');
      }
    } else {
      throw Exception('User not logged in');
    }
  }


  Future<List<Map<String, dynamic>>> loadQuizzes() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _database
            .child('lecturers')
            .child(user.uid)
            .child('quizzes')
            .get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> quizzes = data.entries.map((entry) {
            final quiz = entry.value as Map<dynamic, dynamic>;
            return {
              'id': entry.key,
              'name': quiz['name'],
              'subject': quiz['subject'],
              'createdAt': quiz['createdAt'],
              'questionCount': (quiz['questions'] as List).length,
            };
          }).toList();

          quizzes.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
          return quizzes;
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error loading quizzes: ${e.toString()}');
    }
  }


  Future<void> deleteQuiz(String quizId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _database
          .child('lecturers')
          .child(user.uid)
          .child('quizzes')
          .child(quizId)
          .remove();
    } else {
      throw Exception('User not logged in');
    }
  }


 Future<List<Map<String, dynamic>>> loadAllQuizzes() async {
  try {
    final snapshot = await _database.child('lecturers').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> allQuizzes = [];

      data.forEach((lecturerId, lecturerData) {
        if (lecturerData['quizzes'] != null) {
          final quizzes = lecturerData['quizzes'] as Map<dynamic, dynamic>;
          quizzes.forEach((quizId, quizData) {
            final questions = (quizData['questions'] as List?)?.cast<Map<dynamic, dynamic>>() ?? [];
            
            // Extract description from the last question if available
            String description = 'No description available';
            if (questions.isNotEmpty && questions.last.containsKey('description')) {
              description = questions.last['description'] ?? description;
            }
             String? startTime = quizData['startTime'];
            String? endTime = quizData['endTime'];

            allQuizzes.add({
              'id': quizId,
              'name': quizData['name'],
              'subject': quizData['subject'],
              'createdAt': quizData['createdAt'],
              'questionCount': questions.length,
              'lecturer': lecturerData['name'] ?? 'Unknown Lecturer',
              'questions': questions,
              'description': description,
               'startTime': startTime, // Add startTime to the quiz map
              'endTime': endTime,     // Add endTime to the quiz map
            });
          });
        }
      });

      allQuizzes.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      return allQuizzes;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading quizzes: ${e.toString()}');
    } // Debug: Print error
    throw Exception('Error loading quizzes: ${e.toString()}');
  }
  return [];
}


  List<Map<String, dynamic>> filterQuizzes(
    List<Map<String, dynamic>> allQuizzes,
    String searchTerm,
    String lecturer,
    String subject,
    DateTime? startDate,
    DateTime? endDate
  ) {
    return allQuizzes.where((quiz) {
      bool matchesSearch = quiz['name'].toString().toLowerCase().contains(searchTerm.toLowerCase()) ||
          quiz['subject'].toString().toLowerCase().contains(searchTerm.toLowerCase()) ||
          quiz['lecturer'].toString().toLowerCase().contains(searchTerm.toLowerCase());
      bool matchesLecturer = lecturer == 'All' || quiz['lecturer'].toString() == lecturer;
      bool matchesSubject = subject == 'All' || quiz['subject'].toString() == subject;
      bool matchesDate = true;
      if (startDate != null && endDate != null) {
        DateTime quizDate = DateTime.fromMillisecondsSinceEpoch(int.parse(quiz['createdAt'].toString()));
        matchesDate = quizDate.isAfter(startDate) && quizDate.isBefore(endDate.add(const Duration(days: 1)));
      }
      return matchesSearch && matchesLecturer && matchesSubject && matchesDate;
    }).toList();
  }
Future<List<UserData>> loadUsers() async {
    try {
      DataSnapshot snapshot = await _database.child('users').get();
      Map<dynamic, dynamic>? userTypes = snapshot.value as Map<dynamic, dynamic>?;

      if (userTypes != null) {
        return userTypes.entries.map((entry) {
          return UserData(
            id: entry.key,
            email: entry.value['email'] ?? 'No email',
            userType: entry.value['userType'] ?? 'Unknown',
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  Future<void> saveQuizResults(String quizId, String quizName, List<String>? rightAnswers, List<String>? wrongAnswers, String points, List<Map<dynamic, dynamic>> questions) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    try {
      final quizResult = {
        'quizId': quizId,
        'quizName': quizName,
        'rightAnswers': rightAnswers,
        'wrongAnswers': wrongAnswers,
        'points': points,
        'date': DateTime.now().toIso8601String(),
        'questions': questions, // Add questions here
      };

      await _database.child('students').child(user.uid).child('quizResults').push().set(quizResult);
    } catch (e) {
      throw Exception('Error saving quiz results: ${e.toString()}');
    }
  } else {
    throw Exception('User not logged in');
  }
}

Future<void> saveQuizResults_2(String quizId, String quizName, List<String>? rightAnswers, List<String>? wrongAnswers, String points, List<Map<dynamic, dynamic>> questions, String feedback) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    try {
      final quizResult = {
        'quizId': quizId,
        'quizName': quizName,
        'rightAnswers': rightAnswers,
        'wrongAnswers': wrongAnswers,
        'points': points,
        'date': DateTime.now().toIso8601String(),
        'questions': questions,
        'feedback': feedback,
      };

      await _database.child('students').child(user.uid).child('quizResults').push().set(quizResult);
      await _database.child('students').child(user.uid).child('quizFeedback').push().set(feedback);
    } catch (e) {
      throw Exception('Error saving quiz results: ${e.toString()}');
    }
  } else {
    throw Exception('User not logged in');
  }
}

  Future<void> saveQuizResults_3(String lecturerFeedback, Map<String, dynamic> student) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _database
            .child('students')
            .child(student['userId'])
            .child('quizResults')
            .child(student['quizResultId'])
            .child('lecturerFeedback')
            .push()
            .set(lecturerFeedback);
      } catch (e) {
        throw Exception('Error saving quiz results: ${e.toString()}');
      }
    } else {
      throw Exception('User not logged in');
    }
  }


 Future<List<Map<String, dynamic>>> loadQuizResults() async {
  final User? user = _auth.currentUser;
  if (user != null) {
    final snapshot = await _database
        .child('students')
        .child(user.uid)
        .child('quizResults')
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final result = entry.value as Map<dynamic, dynamic>;
        return {
          'quizId': entry.key,
          'quizName': result['quizName'],
          'rightAnswers': result['rightAnswers'] ?? [],
          'wrongAnswers': result['wrongAnswers'] ?? [],
          'points': result['points'],
          'date': result['date'],
          'feedback': result['feedback'] ?? '',
        };
      }).toList();
    }
  }
  return [];
}

Future<Map<dynamic, dynamic>?> loadQuizDetailsForStudents(String quizId) async {
  final User? user = _auth.currentUser;
  if (user != null) {
    final snapshot = await _database
        .child('students')
        .child(user.uid)
        .child('quizResults')
        .child(quizId)
        .get();

    if (snapshot.exists) {
      // Return the quiz results including the quiz details
      final quizData = snapshot.value as Map<dynamic, dynamic>;
      return {
        'quizId': quizId,
        'quizName': quizData['quizName'],
        'points': quizData['points'],
        'date': quizData['date'],
        'rightAnswers': quizData['rightAnswers'] ?? [],
        'wrongAnswers': quizData['wrongAnswers'] ?? [],
         'questions': quizData['questions'] ?? [],
         'feedback': quizData['feedback'] ?? '',
        
      };
    }
  }
  return null; // Return null if the user is not logged in or quiz not found
}

Future<List<Map<String, dynamic>>> loadCompletedQuizzes() async {
  final User? user = _auth.currentUser;
  if (user != null) {
    try {
      final snapshot = await _database
          .child('students')
          .child(user.uid)
          .child('quizResults')
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> completedQuizzes = [];

        for (var entry in data.entries) {
          final quizData = entry.value as Map<dynamic, dynamic>;
          final quizId = quizData['quizId'];

          // Fetch all quizzes to find questionCount
          final allQuizzes = await loadAllQuizzes();
          final quizInfo = allQuizzes.firstWhere(
            (quiz) => quiz['id'] == quizId,
            orElse: () => {'questionCount': 0}, // Default value
          );

          completedQuizzes.add({
            'quizId': quizId,
            'quizName': quizData['quizName'],
            'rightAnswers': quizData['rightAnswers'],
            'wrongAnswers': quizData['wrongAnswers'],
            'points': quizData['points'],
            'date': quizData['date'],
            'questions': quizData['questions'],
            'questionCount': quizInfo['questionCount'], // Add questionCount
            'feedback': quizData['feedback'] ?? '',
          });
        }

        return completedQuizzes;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error loading completed quizzes: ${e.toString()}');
    }
  } else {
    throw Exception('User not logged in');
  }
}



}

