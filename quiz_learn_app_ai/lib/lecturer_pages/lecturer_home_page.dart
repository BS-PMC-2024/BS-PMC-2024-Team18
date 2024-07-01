import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_question_ai.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_profile_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/my_quizzes_page.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  LecturerHomePageState createState() => LecturerHomePageState();
}

class LecturerHomePageState extends State<LecturerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? userEmail;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent event = await _database.child('users').child(user.uid).once();
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
      setState(() {
        userEmail = user.email;
        userType = userData?['userType'];
      });
    }
  }
    Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, $userEmail'),
            const SizedBox(height: 10),
            Text('User Type: $userType'),
            const SizedBox(height: 20),
             ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateQuestionAI()),
              );
            },
            child: const Text('Create Questions with AI'),
          ),
             ElevatedButton(
            onPressed: () {
           Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyQuizzesPage()),
);
            },
            child: const Text('My Quizzes'),
          ),
            ElevatedButton(
            onPressed: () {
            Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LecturerProfilePage()),
);
            },
            child: const Text('Lecturer Profile'),
          ),
              ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          
          ],
        ),
      ),
    );
  }
}