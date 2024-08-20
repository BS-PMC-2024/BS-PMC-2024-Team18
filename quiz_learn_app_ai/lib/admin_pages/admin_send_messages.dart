import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/services/notification_service.dart';

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
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<List<UserDataToken>> filterUsers() async {
    List<UserDataToken> specialUsers = [];
    _users.forEach((user) async {
      if (user.deviceToken != '') {
        specialUsers.add(user);
      }
    });
    return specialUsers;
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _users = await _firebaseService.loadUsersWithTokens();
      _users = await filterUsers();
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

  Future<void> sendNotificationAllUsers(String? deviceToken, String? body,
      String? title, String? data, BuildContext? context) async {
    body ?? 'this is test message for all users';
    title ?? 'Hi All Users';
    data ?? 'this is data';

    _users.forEach((user) async {
      if (user.deviceToken != '') {
        PushNotifications()
            .sendPushNotifications(user.deviceToken, body, title, data, null);
      }
    });
  }

  Future<void> sendNotificationSpecificUsers(String deviceToken, String? body,
      String? title, String? data, BuildContext? context) async {
    body ?? 'this is test message for Specific user users';
    title ?? 'Hi User';
    data ?? 'this is data';
    _users.forEach((user) async {
      if (user.deviceToken != '') {
        PushNotifications()
            .sendPushNotifications(user.deviceToken, body, title, data, null);
      }
    });
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildUserList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 16.0), // Add padding from the bottom
        child: SizedBox(
          width: 100, // Custom width
          height: 80, // Custom height
          child: FloatingActionButton(
            onPressed: () {
              sendNotificationAllUsers(null, null, null, null, context);
            },
            backgroundColor: Colors.indigo[600],
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message_rounded, color: Colors.white),
                  SizedBox(height: 5), // Space between icon and text
                  Text(
                    'Send to all',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            'Send push notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    return ListView.builder(
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
                PushNotifications().sendPushNotifications(
                    user.deviceToken, null, null, null, context);
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
    );
  }
}

class UserDataToken {
  final String id;
  final String email;
  final String userType;
  final String deviceToken;

  UserDataToken(
      {required this.id,
      required this.email,
      required this.userType,
      required this.deviceToken});
}
