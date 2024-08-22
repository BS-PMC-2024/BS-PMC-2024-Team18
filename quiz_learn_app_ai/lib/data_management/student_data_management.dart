import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:pdf/widgets.dart' as pw;

class StudentDataManagement extends StatefulWidget {
  const StudentDataManagement({super.key});

  @override
  StudentDataManagementState createState() => StudentDataManagementState();
}

class StudentDataManagementState extends State<StudentDataManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<UserDataToken> _users = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    List<UserDataToken> users;
    try {
      users = await _firebaseService.loadUsersWithTokens();
      for (UserDataToken user in users) {
        if (user.userType == 'Student') {
          _users.add(user);
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
                      : _buildStudentDataTable(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _CreateStudentBackUp,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _CreateStudentBackUp() async {
    try {
      // Format data as a string
      String formattedData = _formatDataAsString();

      // Save as TXT
      await _saveAsTxt(formattedData, 'backup.txt');

      // Save as PDF
      await _saveAsPdf(formattedData, 'backup.pdf');
    } catch (e) {
      if (kDebugMode) {
        print('Error backing up data: $e');
      }
    }
  }

  String _formatDataAsString(Map<dynamic, dynamic> data) {
    return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  Future<void> _saveAsTxt(String data, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(data);
    if (kDebugMode) {
      print('Data saved to ${file.path}');
    }
  }

  Future<void> _saveAsPdf(String data, String fileName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(data),
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');
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
            'Student Data Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStudents,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDataTable() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _users
                  .map(
                    (user) => DataRow(
                      cells: [
                        DataCell(Text(user.id)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.userType)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.edit, color: Colors.indigo[400]),
                                onPressed: () => _showEditUserDialog(user),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () => _showDeleteConfirmation(user),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(UserDataToken user) {
    final emailController = TextEditingController(text: user.email);

    // Define the list of valid user types
    final List<String> validUserTypes = ['student', 'lecturer', 'admin'];

    // Ensure the user's type is one of the valid types, defaulting to 'student' if not
    String selectedUserType =
        validUserTypes.contains(user.userType.toLowerCase())
            ? user.userType.toLowerCase()
            : 'student';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled:
                      false, // Email can't be changed easily in Firebase Auth
                ),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  onChanged: (String? newValue) {
                    selectedUserType = newValue!;
                  },
                  items: validUserTypes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'User Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await _database.child('users').child(user.id).update({
                    'userType': selectedUserType,
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  _loadStudents();
                } catch (e) {
                  if (kDebugMode) {
                    print('Error updating user: $e');
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating user: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(UserDataToken user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.email}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  // Delete from Realtime Database
                  await _database.child('users').child(user.id).remove();

                  // Delete from Firebase Authentication
                  // Note: This requires the user to have recently signed in
                  User? currentUser = _auth.currentUser;
                  if (currentUser != null && currentUser.uid == user.id) {
                    await currentUser.delete();
                  } else {
                    // If we're not deleting the current user, we can't delete from Auth
                    // You would typically handle this through a server-side function
                    if (kDebugMode) {
                      print(
                          'Cannot delete user from Auth: not the current user');
                    }
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User deleted successfully')),
                    );
                  }

                  _loadStudents();
                } catch (e) {
                  if (kDebugMode) {
                    print('Error deleting user: $e');
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting user: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
