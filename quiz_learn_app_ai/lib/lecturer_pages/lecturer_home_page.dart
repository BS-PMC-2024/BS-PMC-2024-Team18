import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/loading_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_question_ai.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_profile_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_quiz_statistics_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/my_quizzes_page.dart';
import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  LecturerHomePageState createState() => LecturerHomePageState();
}

class LecturerHomePageState extends State<LecturerHomePage> {
  String? userEmail;
  String? userType;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Auth auth = Auth(auth: FirebaseAuth.instance);
    bool _isLoading = true;
   final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> userData = await _firebaseService.loadUserData();
      if (mounted) {
        setState(() {
          userEmail = _auth.currentUser?.email;
          userType = userData['userType'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
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
      body: _isLoading
        ? const Center(child: LoadingPage())
        : Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              _buildProfileSection(),
                              const SizedBox(height: 40),
                              _buildFeatureGrid(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
Color(0xFFf2b39b), // Lighter #eb8671
Color(0xFFf19b86), // Lighter #ea7059
Color(0xFFf3a292), // Lighter #ef7d5d
Color(0xFFf8c18e), // Lighter #f8a567
Color(0xFFfcd797), // Lighter #fecc63
Color(0xFFcdd7a7), // Lighter #a7c484
Color(0xFF8fb8aa), // Lighter #5b9f8d
Color(0xFF73adbb), // Lighter #257b8c
Color(0xFFcc7699), // Lighter #ad3d75
Color(0xFF84d9db), // Lighter #1fd1d5
Color(0xFF85a8cf), // Lighter #2e7cbc
Color(0xFF8487ac), // Lighter #3d5488
Color(0xFFb7879c), // Lighter #99497f
Color(0xFF86cfd6), // Lighter #23b7c1

        ],
      ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(),
          ),
        ],
      ),
    );
  }
String _formatUserName(String? email) {
  if (email == null || email.isEmpty) {
    return 'Lecturer';
  }
  // Remove everything after and including '@'
  return email.split('@')[0];
}
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Color(0xFF3949AB)),
          ),
          const SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
               'Welcome, ${_formatUserName(userEmail)}',
                textStyle: const TextStyle(fontSize: 22, color: Color(0xFF3949AB), fontWeight: FontWeight.bold),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          Text(
            userType ?? '',
            style: const TextStyle(fontSize: 18, color: Color(0xFF3949AB)),
          ),
        ],
      ),
    );
  }

 Widget _buildFeatureGrid(BuildContext context) {
  final features = [
    {'icon': Icons.search, 'label': 'Quiz Search', 'route': const QuizListScreen()},
    {'icon': Icons.create, 'label': 'Create Questions with AI', 'route': const CreateQuestionAI()},
    {'icon': Icons.quiz, 'label': 'My Quizzes', 'route': const MyQuizzesPage()},
    {'icon': Icons.person, 'label': 'Lecturer Profile', 'route': const LecturerProfilePage()},
     {'icon': Icons.insert_chart, 'label': 'Lecturer Statistics', 'route': const LecturerQuizStatisticsPage()},
  ];

  return Column(
    children: [
      _buildFeatureCard(
        context,
        features[0],
        isFullWidth: true,
      ),
      const SizedBox(height: 20),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
        ),
        itemCount: features.length - 1,
        itemBuilder: (context, index) {
          return _buildFeatureCard(context, features[index + 1]);
        },
      ),
    ],
  );
}

Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature, {bool isFullWidth = false}) {
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => feature['route'])),
    child: Container(
      width: isFullWidth ? double.infinity : null,
      height: isFullWidth ? 60 : null, // Adjusted height for full-width button
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isFullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  feature['label'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  feature['label'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    ),
  );
}

}
