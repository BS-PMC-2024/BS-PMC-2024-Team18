import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_compliance_page.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_dashboard_page.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_quiz_reports_page.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_user_management_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/loading_page.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_settings_page.dart';

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: $result')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during sign out: $e')),
        );
      }
      if (kDebugMode) {
        print("Detailed sign out error: $e");
      }
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
                    Color(0xFFf2b39b),
                    Color(0xFFf19b86),
                    Color(0xFFf3a292),
                    Color(0xFFf8c18e),
                    Color(0xFFfcd797),
                    Color(0xFFcdd7a7),
                    Color(0xFF8fb8aa),
                    Color(0xFF73adbb),
                    Color(0xFFcc7699),
                    Color(0xFF84d9db),
                    Color(0xFF85a8cf),
                    Color(0xFF8487ac),
                    Color(0xFFb7879c),
                    Color(0xFF86cfd6),
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
          icon: Icons.security,
          title: 'Compliance',
          description: 'Ensures compliance with data security and privacy regulations.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminCompliancePage()),
            );
          },
        ),
          _buildActionCard(
          icon: Icons.report,
          title: 'Quiz reports',
          description: 'Ensures quizs with data security and privacy regulations.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminQuizReportsPage()),
            );
          },
        ),
                  _buildActionCard(
          icon: Icons.query_stats,
          title: 'Admin dashboard',
          description: 'See more details about reports and more.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
            );
          },
        ),
        _buildActionCard(
  icon: Icons.settings,
  title: 'Platform Settings',
  description: 'Manage platform-wide settings and configurations',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminSettingsPage()),
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