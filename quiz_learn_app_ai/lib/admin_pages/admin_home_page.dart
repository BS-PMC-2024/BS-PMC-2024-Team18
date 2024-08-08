import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_compliance_page.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_user_management_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/loading_page.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {

  String? userEmail;
  String? userType;
   bool _isLoading = true;
     final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseService _firebaseService = FirebaseService();
    final Auth auth = Auth(auth: FirebaseAuth.instance);
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
        : Container(
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
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Admin Dashboard',
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
    );
  }

  Widget _buildContent() {
    if (userEmail == null || userType == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 30),
            _buildAdminActions(),
          ],
        ),
      ),
    );
  }
String _formatUserName(String? email) {
  if (email == null || email.isEmpty) {
    return 'Admin';
  }
  // Remove everything after and including '@'
  return email.split('@')[0];
}
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigo[100],
                child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.indigo[800]),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                            'Welcome, ${_formatUserName(userEmail)}',
                          textStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                    Text(
                      userEmail!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'User Type: $userType',
            style: TextStyle(
              fontSize: 16,
              color: Colors.indigo[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        const SizedBox(height: 15),
        _buildActionCard(
          icon: Icons.people,
          title: 'User Management',
          description: 'Manage users, roles, and permissions',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminUserManagementPage()),
            );
          },
        ),
      _buildActionCard(
          icon: Icons.people,
          title: 'Compliance',
          description: 'Ensures compliance with data security and privacy regulations.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminCompliancePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.indigo[600]),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.indigo[400]),
            ],
          ),
        ),
      ),
    );
  }
}