import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/auth_pages/loading_page.dart';
import 'package:quiz_learn_app_ai/data_management/lecturer_data_management.dart';
import 'package:quiz_learn_app_ai/data_management/quiz_data_management.dart';
import 'package:quiz_learn_app_ai/data_management/student_data_management.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class BackUpAndDataManagement extends StatefulWidget {
  const BackUpAndDataManagement({super.key});
  @override
  BackUpAndDataManagementState createState() => BackUpAndDataManagementState();
}

class BackUpAndDataManagementState extends State<BackUpAndDataManagement> {
  final PushNotifications pushNotifications = PushNotifications();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  String? userEmail;
  String? userType;

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
        await pushNotifications.requestPermission();
        await pushNotifications.generateDeviceToken();
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
                child: Icon(Icons.manage_history_rounded,
                    size: 30, color: Colors.indigo[800]),
              ),
              const SizedBox(width: 15),
              Text(
                userEmail!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo[600],
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
          'Data',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        const SizedBox(height: 15),
        _buildActionCard(
          icon: Icons.school_rounded,
          title: 'Manage Students data',
          description: 'Manage students data and more.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StudentDataManagement()),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.assignment_rounded,
          title: 'Manage Lecturers data',
          description: 'Manage lecturers data and more.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LecturerDataManagement()),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.quiz_rounded,
          title: 'Manage Quiz Data',
          description: 'Manage quiz data and more.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const QuizDataManagement()),
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
