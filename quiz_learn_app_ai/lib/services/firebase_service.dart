// firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _database;
 final FirebaseAuth _auth;
 
  FirebaseService({DatabaseReference? database , FirebaseAuth? auth})
      : _database = database ?? FirebaseDatabase.instance.ref(),   _auth = auth ?? FirebaseAuth.instance;




  Future<void> saveQuiz(String quizId, String quizName, List<Map<dynamic, dynamic>> questions, String description) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _database
          .child('lecturers')
          .child(user.uid)
          .child('quizzes')
          .child(quizId)
          .update({
        'name': quizName,
        'questions': questions,
        'description': description,
      });
    } else {
      throw Exception('User not authenticated');
    }
  }

   Future<void> saveQuizToFirebase(String quizName, String subject, List<Map<String, dynamic>> questions) async {
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
}
