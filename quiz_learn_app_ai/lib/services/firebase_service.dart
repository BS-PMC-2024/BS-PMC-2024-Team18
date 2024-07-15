// firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_user_management_page.dart';

class FirebaseService {
  final DatabaseReference _database;
 final FirebaseAuth _auth;
 
  FirebaseService({DatabaseReference? database , FirebaseAuth? auth})
      : _database = database ?? FirebaseDatabase.instance.ref(),   _auth = auth ?? FirebaseAuth.instance;



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

Future<void> updateQuiz(String quizId, String quizName, List<Map<dynamic, dynamic>> questions, String description) async {
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
              allQuizzes.add({
                'id': quizId,
                'name': quizData['name'],
                'subject': quizData['subject'],
                'createdAt': quizData['createdAt'],
                'questionCount': (quizData['questions'] as List).length,
                'lecturer': lecturerData['name'] ?? 'Unknown Lecturer',
              });
            });
          }
        });

        allQuizzes.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        return allQuizzes;
      }
    } catch (e) {
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

   Future<void> saveQuizResults(String quizId, String quizName, List<String>? rightAnswers, List<String>? wrongAnswers, String points) async {
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
        };

        await _database.child('students').child(user.uid).child('quizResults').push().set(quizResult);
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
    try {
      final snapshot = await _database
          .child('students')
          .child(user.uid)
          .child('quizResults')
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> results = data.entries.map((entry) {
          final result = entry.value as Map<dynamic, dynamic>;
          return {
            'quizId': result['quizId'],
            'quizName': result['quizName'],
            'rightAnswers': result['rightAnswers'],
            'wrongAnswers': result['wrongAnswers'],
            'points': result['points'],
            'date': result['date'],
          };
        }).toList();

        results.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        return results;
      }
    } catch (e) {
      throw Exception('Error loading quiz results: ${e.toString()}');
    }
  }
  throw Exception('User not logged in');
}

}

