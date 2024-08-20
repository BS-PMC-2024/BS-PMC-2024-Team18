import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/services/notification_service.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({super.key});
  @override
  ReportIssueState createState() => ReportIssueState();
}

class ReportIssueState extends State<ReportIssue> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  List<UserDataToken> _admins = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _bodyMessageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
    });
    List<UserDataToken> users = [];
    try {
      users = await _firebaseService.loadUsersWithTokens();
      for (UserDataToken user in users) {
        if (user.userType == 'Admin' && user.deviceToken != '') {
          _admins.add(user);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // You might want to show a snackbar or some other error indication to the user here
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

//   Future<void> _loadUserData() async {
//   final user = _auth.currentUser;
//   if (user != null) {
//     try {
//       final snapshot = await _database.child('').child(user.uid).get();
//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           _nameController.text = data['name']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//           _phoneController.text = data['phone']?.toString() ?? '';
//           _majorController.text = data['major']?.toString() ?? '';
//           _yearOfStudyController.text = data['yearOfStudy']?.toString() ?? '';
//           _bioController.text = data['bio']?.toString() ?? '';
//           _courses = List<String>.from(data['courses'] ?? []);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading user data: ${e.toString()}')),
//         );
//       }
//     }
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFeb8671), // #eb8671
              Color(0xFFea7059), // #ea7059
              Color(0xFFef7d5d), // #ef7d5d
              Color(0xFFf8a567), // #f8a567
              Color(0xFFfecc63), // #fecc63
              Color(0xFFa7c484), // #a7c484
              Color.fromARGB(255, 175, 223, 210), // #5b9f8d
              Color(0xFF257b8c), // #257b8c
              Color(0xFFad3d75), // #ad3d75
              Color(0xFF1fd1d5), // #1fd1d5
              Color(0xFF2e7cbc), // #2e7cbc
              Color(0xFF3d5488), // #3d5488
              Color(0xFF99497f), // #99497f
              Color(0xFF23b7c1), // #23b7c1
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
                  child: _buildReportForm(),
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
            'Report Issue',
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

  Widget _buildReportForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: _subjectController,
              label: 'Report Subject',
              icon: Icons.subject_rounded,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter Subject of problem' : null,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _bodyMessageController,
              label: 'Report Body',
              icon: Icons.report_rounded,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter body of problem' : null,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => sendReportToAdmins(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Report', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Future sendReportToAdmins(BuildContext? context) async {
    final User? user = _auth.currentUser;
    String? subject = _subjectController.text;
    String data = _bodyMessageController.text;
    data ?? 'SPAM';
    subject ?? 'SPAM';
    String title = 'Issue Report';
    List<String> _adminsEmails = [];
    _admins.forEach((admin) {
      _adminsEmails.add(admin.email);
    });

    _admins.forEach((admin) async {
      try {
        PushNotifications().sendPushNotifications(
            admin.deviceToken, subject, title, data, context);
      } catch (e) {
        if (kDebugMode) {
          print('Error sending message: $e');
        }
      }
    });
    if (kDebugMode) {
      print('Report sent to admins: $subject - $data');
    }
    try {
      //save report to database
      final issueReport = {
        'title': title,
        'subject': subject,
        'data': data,
        'date': DateTime.now().toIso8601String(),
        'sender': user!.uid,
        'senderEmail': user.email,
        'InformedAdmins': _adminsEmails,
      };

      await _database.child('issue_reports').push().set(issueReport);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving report to database: $e');
      }
    }
  }
}
