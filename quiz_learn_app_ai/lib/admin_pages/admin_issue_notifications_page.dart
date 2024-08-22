import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/auth_pages/loading_page.dart';
import 'package:quiz_learn_app_ai/notifications/admin_message.dart';
import 'package:quiz_learn_app_ai/notifications/issue_report_message.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class AdminIssueNotificationReport extends StatefulWidget {
  const AdminIssueNotificationReport({super.key});

  @override
  AdminIssueNotificationReportState createState() =>
      AdminIssueNotificationReportState();
}

class AdminIssueNotificationReportState
    extends State<AdminIssueNotificationReport> {
  List<IssueReportNotifications> issueReports = [];
  List<AdminMessage> adminReports = [];
  Set<int> expandedIssueMessages = {};
  Set<int> expandedAdminReports = {};
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    await _loadIssueReports();
    await _loadAdminReports();
  }

  Future<void> _loadAdminReports() async {
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
      final DataSnapshot snapshot =
          await _database.child('issue_reports').child('admin_reports').get();

      final data = snapshot.value;
      if (data != null) {
        final messagesMap =
            Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
        setState(() {
          adminReports = messagesMap.values
              .map((messageData) =>
                  AdminMessage.fromMap(Map<dynamic, dynamic>.from(messageData)))
              .toList();
        });
      }

      // Start listening for changes
      _database
          .child('issue_reports')
          .child('admin_reports')
          .onValue
          .listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          final messagesMap =
              Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            adminReports = messagesMap.values
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

  Future<void> _loadIssueReports() async {
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
      final DataSnapshot snapshot =
          await _database.child('issue_reports').child('general_reports').get();

      final data = snapshot.value;
      if (data != null) {
        final messagesMap =
            Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
        setState(() {
          issueReports = messagesMap.values
              .map((messageData) => IssueReportNotifications.fromMap(
                  Map<dynamic, dynamic>.from(messageData)))
              .toList();
        });
      }

      // Start listening for changes
      _database
          .child('issue_reports')
          .child('general_reports')
          .onValue
          .listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          final messagesMap =
              Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
          setState(() {
            issueReports = messagesMap.values
                .map((messageData) => IssueReportNotifications.fromMap(
                    Map<dynamic, dynamic>.from(messageData)))
                .toList();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading report notifications: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> removeIssueReportMessage(
      IssueReportNotifications message) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }
    try {
      await _database
          .child('issue_reports')
          .child('general_reports')
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
          .child('issue_reports')
          .child('admin_reports')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        if (issueReports.isNotEmpty) _buildIssueReportsCard(),
        if (adminReports.isNotEmpty) _buildAdminReportsCard(),
      ],
    );
  }

  Widget _buildIssueReportsCard() {
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
              'Issue Reports',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ),
          _buildIssueReportsList(),
        ],
      ),
    );
  }

  Widget _buildIssueReportsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: issueReports.length,
      itemBuilder: (context, index) {
        final message = issueReports[index];
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
                  message.getFormattedDate(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  setState(() {
                    if (expandedIssueMessages.contains(index)) {
                      expandedIssueMessages.remove(index);
                    } else {
                      expandedIssueMessages.add(index);
                    }
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      issueReports.removeAt(index);
                      removeIssueReportMessage(message);
                    });
                  },
                ),
              ),
              if (expandedIssueMessages.contains(index))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject: ${message.subject}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Issue: ${message.data}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sender ID: ${message.sender}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sender Email: ${message.senderEmail}',
                        style: TextStyle(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Informed Admins: ${message.informedAdmins.join(', ')}',
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

  Widget _buildAdminReportsCard() {
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
              'Admin Reports',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ),
          _buildAdminReportsList(),
        ],
      ),
    );
  }

  Widget _buildAdminReportsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminReports.length,
      itemBuilder: (context, index) {
        final message = adminReports[index];
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
                  message.getFormattedDate(), // Format date without seconds
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  setState(() {
                    if (expandedAdminReports.contains(index)) {
                      expandedAdminReports.remove(index);
                    } else {
                      expandedAdminReports.add(index);
                    }
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      adminReports.removeAt(index);
                      removeAdminNotificationFromDb(message);
                    });
                  },
                ),
              ),
              if (expandedAdminReports.contains(index))
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
            'Issue Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadIssueReports,
          ),
        ],
      ),
    );
  }
}
