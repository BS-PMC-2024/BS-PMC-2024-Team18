import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';

class SendToSpecificUser extends StatefulWidget {
  final UserDataToken user;
  const SendToSpecificUser({super.key, required this.user});
  @override
  SendToSpecificUserState createState() => SendToSpecificUserState();
}

class SendToSpecificUserState extends State<SendToSpecificUser> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final TextEditingController _bodyMessageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  late UserDataToken user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

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
          Column(
            children: [
              const Text(
                'Send notification to ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )),
            ],
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
                  value!.isEmpty ? 'Please enter Subject ' : null,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _bodyMessageController,
              label: 'Report Body',
              icon: Icons.report_rounded,
              validator: (value) => value!.isEmpty ? 'Please enter body' : null,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => sendNotificationSpecificUsers(user, context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Message', style: TextStyle(fontSize: 18)),
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

  Future<void> sendNotificationSpecificUsers(
      UserDataToken user, BuildContext? context) async {
    final aUser = _auth.currentUser;
    String? body = _bodyMessageController.text;
    String? title = _subjectController.text;
    String data = 'this is data';
    String notificationId = '';
    DatabaseReference ref = _database.child('default');

    if (user.userType == 'Student') {
      PushNotifications()
          .sendPushNotifications(user.deviceToken, body, title, data, null);
      ref = _database
          .child('students')
          .child(user.id)
          .child('notifications')
          .child('notificationFromAdmin')
          .push();
      notificationId = ref.key!;
    } else if (user.userType == 'Teacher') {
      PushNotifications()
          .sendPushNotifications(user.deviceToken, body, title, data, null);
      ref = _database
          .child('lecturers')
          .child(user.id)
          .child('notifications')
          .child('notificationFromAdmin')
          .push();
      notificationId = ref.key!;
    } else {
      PushNotifications()
          .sendPushNotifications(user.deviceToken, body, title, data, null);
      ref = _database.child('issue_reports').child('admin_reports').push();
      notificationId = ref.key!;
    }
    final message = {
      'subject': title,
      'message': body,
      'date': DateTime.now().toIso8601String(),
      'AdminEmail': aUser!.email,
      'notificationId': notificationId,
    };
    try {
      await ref.set(message);
      if (mounted) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
              content:
                  Text('message sent successfully to user: ${user.email}')),
        );
      }
      if (kDebugMode) {
        print('Notification sent with ID: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification to database: $e');
      }
    }
  }
}
