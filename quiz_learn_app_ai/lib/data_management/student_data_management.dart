import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/data_management/data_backups/pdf_generator.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

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
    
    try {
      _users = await _firebaseService.loadUsersWithTokens();
      _users.removeWhere((user) => user.userType.toLowerCase() == 'admin' || user.userType.toLowerCase() == 'lecturer');
    } catch (e) {
      if (kDebugMode) {
        print('Error loading student: $e');
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
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildStudentDataTable(context),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _backupData,
        backgroundColor: Colors.indigo[600],
        icon: const Icon(Icons.data_saver_on_outlined, color: Colors.white),
        label: const Text(
          'Save Data snapshot',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _backupData() async {
    try {
      final file = await PdfGenerator.generateUserDataPdf(_users);
      saveUserDataToTextFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating backup: $e')),
        );
      }
    }
  }

  Future<void> saveUserDataToTextFile() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    // Define the path for the file
    final path =
        Directory('${directory.path}/lib/data_management/data_backups');

    // Create the directory if it doesn't exist
    if (!await path.exists()) {
      await path.create(recursive: true);
    }

    // Define the file path and name
    final filePath =
        '${path.path}/user_data_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(filePath);

    // Prepare the content for the file
    StringBuffer content = StringBuffer();
    content.writeln('ID, Email, User Type, Device Token');
    for (UserDataToken user in _users) {
      content.writeln(
          '${user.id}, ${user.email}, ${user.userType}, ${user.deviceToken}');
    }

    // Write the content to the file
    await file.writeAsString(content.toString());

    if (kDebugMode) {
      print('txt File saved at: $filePath');
    }
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
              fontSize: 20,
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

  Widget _buildStudentDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: DataTable(
                columnSpacing: 20.0,
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.indigo[100]!),
                border:
                    TableBorder.all(borderRadius: BorderRadius.circular(10)),
                columns: [
                  DataColumn(
                      label: Center(
                          child: Text('ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Email',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Type',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Token ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Actions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                ],
                rows: _users
                    .map(
                      (user) => DataRow(
                        cells: [
                          DataCell(Text(user.id,
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(user.email,
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(user.userType,
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(user.deviceToken != '' ? 'Yes' : 'No',
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.indigo[400]),
                                    onPressed: () => _showEditUserDialog(user),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red[400]),
                                    onPressed: () =>
                                        _showDeleteConfirmation(user),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
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
          title: const Text('Edit student'),
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
                    print('Error updating student: $e');
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating student: $e')),
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
          title: const Text('Delete student'),
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
                          content: Text('student deleted successfully')),
                    );
                  }

                  _loadStudents();
                } catch (e) {
                  if (kDebugMode) {
                    print('Error deleting student: $e');
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting student: $e')),
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
