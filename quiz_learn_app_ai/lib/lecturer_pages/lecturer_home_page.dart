import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_question_ai.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_profile_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/my_quizzes_page.dart';
import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';


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
    final Auth auth = Auth(auth: FirebaseAuth.instance);

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
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          userEmail = user.email;
          userType = userData?['userType'];
        });
      }
    }
  }

Future<void> _signOut() async {
  try {
    String result = await auth.signOut();
    
    if (result == "Success") {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
        );
      }
    } else {
      // Handle sign out failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $result')),
        );
      }
    }
  } catch (e) {
    // Handle any unexpected errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during sign out: $e')),
      );
    }
    if (kDebugMode) {
      print("Detailed sign out error: $e");
    } // For debugging
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[400]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CampusQuest AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _signOut,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 50, color: Colors.blue[800]),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome, ${userEmail ?? 'Lecturer'}',
                            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userType ?? '',
                            style: const TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          const SizedBox(height: 40),
                          _buildButton(
                            icon: Icons.create,
                            label: 'Create Questions with AI',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateQuestionAI())),
                          ),
                          const SizedBox(height: 20),
                          _buildButton(
                            icon: Icons.quiz,
                            label: 'My Quizzes',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyQuizzesPage())),
                          ),
                          const SizedBox(height: 20),
                          _buildButton(
                            icon: Icons.person,
                            label: 'Lecturer Profile',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LecturerProfilePage())),
                          ),
                            const SizedBox(height: 20),
                          _buildButton(
                            icon: Icons.person,
                            label: 'Quiz Search',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  const QuizListScreen())),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
