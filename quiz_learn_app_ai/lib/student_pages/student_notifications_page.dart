import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/notifications/admin_message.dart';
import 'package:quiz_learn_app_ai/notifications/lecturer_message.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class StudentNotification extends StatefulWidget {
  const StudentNotification({super.key});

  @override
  StudentNotificationState createState() => StudentNotificationState();
}

class StudentNotificationState extends State<StudentNotification> {
  List<AdminMessage> adminMessages = [];
  List<LecturerMessage> lecturerMessages = [];
  Set<int> expandedLecturerMessages = {};
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
    await _loadLecturerMessages();
    await _loadAdminMessages();
  }

  Future<void> _loadLecturerMessages() async {
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
          .child('students')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromLecturer')
          .get();

      final data = snapshot.value;
      if (data != null) {
        final messagesMap =
            Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
        setState(() {
          lecturerMessages = messagesMap.values
              .map((messageData) => LecturerMessage.fromMap(
                  Map<dynamic, dynamic>.from(messageData)))
              .toList();
        });
      }

      // Start listening for changes
      _database
          .child('students')
          .child(user.uid)
          .child('notifications')
          .child('notificationFromLecturer')
          .onValue
          .listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          final messagesMap =
              Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            lecturerMessages = messagesMap.values
                .map((messageData) => LecturerMessage.fromMap(
                    Map<dynamic, dynamic>.from(messageData)))
                .toList();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading lecturer messages: $e');
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
          .child('students')
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
          .child('students')
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

  Future<void> removeStudentNotificationFromDb(LecturerMessage message) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }
    try {
      await _database
          .child('students')
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
    if (context.mounted) {
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
          .child('students')
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
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted successfully')),
      );
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       decoration: const BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [
  //             Color(0xFFeb8671), // #eb8671
  //             Color(0xFFea7059), // #ea7059
  //             Color(0xFFef7d5d), // #ef7d5d
  //             Color(0xFFf8a567), // #f8a567
  //             Color(0xFFfecc63), // #fecc63
  //             Color(0xFFa7c484), // #a7c484
  //             Color.fromARGB(255, 175, 223, 210), // #5b9f8d
  //             Color(0xFF257b8c), // #257b8c
  //             Color(0xFFad3d75), // #ad3d75
  //             Color(0xFF1fd1d5), // #1fd1d5
  //             Color(0xFF2e7cbc), // #2e7cbc
  //             Color(0xFF3d5488), // #3d5488
  //             Color(0xFF99497f), // #99497f
  //             Color(0xFF23b7c1), // #23b7c1
  //           ],
  //         ),
  //       ),
  //       child: SafeArea(
  //         child: Column(
  //           children: [
  //             _buildAppBar(),
  //             Expanded(
  //               child: Container(
  //                 decoration: const BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(30),
  //                     topRight: Radius.circular(30),
  //                   ),
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     lecturerMessages.isEmpty
  //                         ? const SizedBox()
  //                         : Text(
  //                             'Lecturer Messages',
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.indigo[800],
  //                             ),
  //                           ),
  //                     const SizedBox(height: 10),
  //                     _isLoading
  //                         ? const Center(child: CircularProgressIndicator())
  //                         : _buildLecturerMessagesList(),
  //                     const SizedBox(height: 20),
  //                     adminMessages.isEmpty
  //                         ? const SizedBox()
  //                         : Text(
  //                             'Admin Messages',
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.indigo[800],
  //                             ),
  //                           ),
  //                     _isLoading
  //                         ? const Center(child: CircularProgressIndicator())
  //                         : _buildAdminMessagesList(),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
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

// Adjusted _buildMessages method
  Widget _buildMessages() {
    return ListView(
      children: [
        if (lecturerMessages.isNotEmpty) _buildLecturerMessagesCard(),
        if (adminMessages.isNotEmpty) _buildAdminMessagesCard(),
      ],
    );
  }

// Adjusted _buildLecturerMessagesCard method
  Widget _buildLecturerMessagesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure Column takes only needed space
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Lecturer Messages',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ),
          _buildLecturerMessagesList(),
        ],
      ),
    );
  }

// Adjusted _buildAdminMessagesCard method
  Widget _buildAdminMessagesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure Column takes only needed space
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

// Adjusted _buildLecturerMessagesList method
  Widget _buildLecturerMessagesList() {
    return ListView.builder(
      shrinkWrap: true, // Allow ListView to shrink-wrap its content
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
      itemCount: lecturerMessages.length,
      itemBuilder: (context, index) {
        final message = lecturerMessages[index];
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
                    message.lectureEmail[0].toUpperCase(),
                    style: TextStyle(
                        color: Colors.indigo[800], fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  message.quizName.capitalize(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  message.getFormattedDate().toString(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  setState(() {
                    if (expandedLecturerMessages.contains(index)) {
                      expandedLecturerMessages.remove(index);
                    } else {
                      expandedLecturerMessages.add(index);
                    }
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      lecturerMessages.removeAt(index);
                      removeStudentNotificationFromDb(message);
                    });
                  },
                ),
              ),
              if (expandedLecturerMessages.contains(index))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Description: ${message.description}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lecturer Email: ${message.lectureEmail}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Type: ${message.type}',
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

// Adjusted _buildAdminMessagesList method
  Widget _buildAdminMessagesList() {
    return ListView.builder(
      shrinkWrap: true, // Allow ListView to shrink-wrap its content
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
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
