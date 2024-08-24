import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/notifications/admin_message.dart';
import 'package:quiz_learn_app_ai/notifications/student_message.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class LecturerNotification extends StatefulWidget {
  const LecturerNotification({super.key});

  @override
  LecturerNotificationState createState() => LecturerNotificationState();
}

class LecturerNotificationState extends State<LecturerNotification> {
  List<AdminMessage> adminMessages = [];
  List<StudentMessage> studentMessages = [];
  Set<int> expandedStudentMessages = {};
  Set<int> expandedAdminMessages = {};
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    await _loadStudentMessages();
    await _loadAdminMessages();
  }

  Future<void> _loadStudentMessages() async {
    setState(() {
      _isLoading = true;
    });
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      // Load existing messages
      final DataSnapshot snapshot = await _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromStudent')
          .get();

      final data = snapshot.value;
      if (data != null) {
        final messagesMap =
            Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
        setState(() {
          studentMessages = messagesMap.values
              .map((messageData) => StudentMessage.fromMap(
                  Map<dynamic, dynamic>.from(messageData)))
              .toList();
        });
      }

      // Start listening for changes
      _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromStudent')
          .onValue
          .listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          final messagesMap =
              Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            studentMessages = messagesMap.values
                .map((messageData) => StudentMessage.fromMap(
                    Map<dynamic, dynamic>.from(messageData)))
                .toList();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Student messages: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAdminMessages() async {
    setState(() {
      _isLoading = true;
    });
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      // Load existing messages
      final DataSnapshot snapshot = await _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromAdmin')
          .get();

      final data = snapshot.value;
      if (data != null) {
        final messagesMap =
            Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
        setState(() {
          adminMessages = messagesMap.values
              .map((messageData) =>
                  AdminMessage.fromMap(Map<dynamic, dynamic>.from(messageData)))
              .toList();
        });
      }

      // Start listening for changes
      _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromAdmin')
          .onValue
          .listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          final messagesMap =
              Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            adminMessages = messagesMap.values
                .map((messageData) => AdminMessage.fromMap(
                    Map<dynamic, dynamic>.from(messageData)))
                .toList();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading admin messages: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> removeStudentNotificationFromDb(StudentMessage message) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }
    try {
      await _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromStudent')
          .child(message.notificationId)
          .remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing message: $e');
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted successfully')),
      );
    }
  }

  Future<void> removeAdminNotificationFromDb(AdminMessage message) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }
    try {
      await _database
          .child('lecturers')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromAdmin')
          .child(message.notificationId)
          .remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing message: $e');
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted successfully')),
      );
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMessages(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView(
      children: [
        if (studentMessages.isNotEmpty) _buildStudentMessagesCard(),
        if (adminMessages.isNotEmpty) _buildAdminMessagesCard(),
      ],
    );
  }

  Widget _buildStudentMessagesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Student Messages',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ),
          _buildStudentMessagesList(),
        ],
      ),
    );
  }

  Widget _buildStudentMessagesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: studentMessages.length,
      itemBuilder: (context, index) {
        final message = studentMessages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Text(
                    message.senderEmail[0].toUpperCase(),
                    style: TextStyle(
                        color: Colors.indigo[800], fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  message.title.capitalize(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  message.getFormattedDate().toString(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  setState(() {
                    if (expandedStudentMessages.contains(index)) {
                      expandedStudentMessages.remove(index);
                    } else {
                      expandedStudentMessages.add(index);
                    }
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      studentMessages.removeAt(index);
                      removeStudentNotificationFromDb(message);
                    });
                  },
                ),
              ),
              if (expandedStudentMessages.contains(index))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message: ${message.body}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Student Email: ${message.senderEmail}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Type: ${message.data}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminMessagesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Admin Messages',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ),
          _buildAdminMessagesList(),
        ],
      ),
    );
  }

  Widget _buildAdminMessagesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminMessages.length,
      itemBuilder: (context, index) {
        final message = adminMessages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Text(
                    message.adminEmail[0].toUpperCase(),
                    style: TextStyle(
                        color: Colors.indigo[800], fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  message.subject.capitalize(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  message.getFormattedDate().toString(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  setState(() {
                    if (expandedAdminMessages.contains(index)) {
                      expandedAdminMessages.remove(index);
                    } else {
                      expandedAdminMessages.add(index);
                    }
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      adminMessages.removeAt(index);
                      removeAdminNotificationFromDb(message);
                    });
                  },
                ),
              ),
              if (expandedAdminMessages.contains(index))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message: ${message.message}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Admin Email: ${message.adminEmail}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
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
            'My Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
    );
  }
}
