import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_message_to_specific_user.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class AdminSendMessages extends StatefulWidget {
  const AdminSendMessages({super.key});

  @override
  AdminSendMessagesState createState() => AdminSendMessagesState();
}

class AdminSendMessagesState extends State<AdminSendMessages> {
  List<UserDataToken> _users = [];
  final _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  User aUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _bodyMessageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  UserDataToken tempUser = UserDataToken(
      id: '999999999999', email: '', userType: '', deviceToken: '');
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<List<UserDataToken>> filterUsers() async {
    List<UserDataToken> specialUsers = [];
  for (final user in _users) {
  if (user.deviceToken != '') {
    specialUsers.add(user);
  }
}
    return specialUsers;
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _users = await _firebaseService.loadUsersWithTokens();
      _users = await filterUsers();
      for (UserDataToken user in _users) {
        if (user.id == aUser.uid) {
          tempUser = user;
          _users.remove(user);
          break;
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

Future<void> sendNotificationAllUsers(BuildContext? context) async {
  String body = _bodyMessageController.text;
  String title = _subjectController.text;
  String data = 'this is data';
  
  try {
    for (final user in _users) {
      if (user.deviceToken != '' && user.deviceToken != tempUser.deviceToken) {
        await PushNotifications().sendPushNotifications(
          user.deviceToken, body, title, data, context);

        late DatabaseReference ref;
        late String notificationId;

        switch (user.userType.toLowerCase()) {
          case 'student':
            ref = _database
                .child('students')
                .child(user.id)
                .child('notifications')
                .child('notificationFromAdmin')
                .push();
            break;
          case 'lecturer':
            ref = _database
                .child('lecturers')
                .child(user.id)
                .child('notifications')
                .child('notificationFromAdmin')
                .push();
            break;
          default:
            ref = _database.child('issue_reports').child('admin_reports').push();
        }

        notificationId = ref.key!;

        final message = {
          'subject': title,
          'message': body,
          'date': DateTime.now().toIso8601String(),
          'AdminEmail': aUser.email,
          'notificationId': notificationId,
        };

        try {
          await ref.set(message);
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

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent to all users successfully')),
      );
      _bodyMessageController.clear();
      _subjectController.clear();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error sending notification: $e');
    }
  }
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _subjectController,
                          label: 'Subject',
                          icon: Icons.subject_rounded,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter Subject of message'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _bodyMessageController,
                          label: 'Message ',
                          icon: Icons.report_rounded,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter body of Message'
                              : null,
                          maxLines: 2,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => sendNotificationAllUsers(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(
                                  100, 50), // Set the minimum width and height
                              maximumSize: const Size(350, 50),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Send Notification to All Users',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildUserList(),
                      ],
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
        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Send push notifications',
              style: TextStyle(
                fontSize: 22, // Slightly reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadUsers,
        ),
      ],
    ),
  );
}
  Widget _buildUserList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[100],
                child: Text(
                  user.email[0].toUpperCase(),
                  style: TextStyle(
                      color: Colors.indigo[800], fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                user.email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'User Type: ${user.userType.capitalize()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendToSpecificUser(
                        user: user,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.message_rounded, color: Colors.indigo[400]),
                    const SizedBox(height: 5),
                    Text(
                      "Send Notification",
                      style: TextStyle(color: Colors.indigo[400], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 2,
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
}

class UserDataToken {
  final String id;
  final String email;
  final String userType;
  String deviceToken;

  UserDataToken(
      {required this.id,
      required this.email,
      required this.userType,
      required this.deviceToken});
}
