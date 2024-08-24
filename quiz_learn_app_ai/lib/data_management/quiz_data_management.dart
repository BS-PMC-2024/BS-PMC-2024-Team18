import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_learn_app_ai/data_management/data_backups/pdf_generator.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';

class QuizDataManagement extends StatefulWidget {
  const QuizDataManagement({super.key});

  @override
  QuizDataManagementState createState() => QuizDataManagementState();
}

class QuizDataManagementState extends State<QuizDataManagement> {
  List<Map<String, dynamic>> _allQuizzes = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  final _database = FirebaseDatabase.instance.ref();
  @override
  void initState() {
    super.initState();
    _loadAllQuizzes();
  }

  Future<void> _loadAllQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Assuming you have an instance of FirebaseService called _firebaseService
      _allQuizzes = await _firebaseService.loadAllQuizzes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
        );
      }
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
                      : _buildQuizDataTable(context),
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
      final pdfFile = await PdfGenerator.generateQuizDataPdf(_allQuizzes);
      if(mounted){
          await saveQuizDataToTextFile(_allQuizzes, context);
      }
    
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to: ${pdfFile.path}')),
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



Future<void> saveQuizDataToTextFile(List<Map<String, dynamic>> quizzes, BuildContext context) async {
  try {
    // Request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission is required to save the file');
      }
    }

    // Get the Downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access the Downloads directory');
    }

    // Define the file path and name
    final fileName = 'quiz_data_${DateTime.now().millisecondsSinceEpoch}.txt';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Prepare the content for the file
    StringBuffer content = StringBuffer();
    content.writeln(
        'ID, Name, Subject, Created At, Questions Count, Lecturer, Description, Lecturer ID, Start Time, End Time');
    for (var quiz in quizzes) {
      content.writeln(
          '${quiz['id']}, ${quiz['name']}, ${quiz['subject']}, ${quiz['createdAt']}, ${quiz['questionCount']}, ${quiz['lecturer']}, ${quiz['description']}, ${quiz['lecturerId']}, ${quiz['startTime']}, ${quiz['endTime']}');
    }

    // Write the content to the file
    await file.writeAsString(content.toString());

    if (kDebugMode) {
      print('txt File saved at: $filePath');
    }

    // Show a success message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to Downloads: $fileName')),
      );
    }

    // Open the file automatically
    OpenFile.open(filePath);
  } catch (e) {
    if (kDebugMode) {
      print('Error saving file: $e');
    }
    // Show an error message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
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
        const Flexible(
          child: Center(
            child: Text(
              'Quizzes Data Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadAllQuizzes,
        ),
      ],
    ),
  );
}

  Widget _buildQuizDataTable(BuildContext context) {
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
                          child: Text('Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Subject',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Created At',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Questions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800])))),
                  DataColumn(
                      label: Center(
                          child: Text('Lecturer',
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
                rows: _allQuizzes
                    .map(
                      (quiz) => DataRow(
                        cells: [
                          DataCell(Text(quiz['id'].toString(),
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(quiz['name'] ?? 'N/A',
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(quiz['subject'] ?? 'N/A',
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(quiz['createdAt'].toString(),
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(quiz['questionCount'].toString(),
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(Text(quiz['lecturer'],
                              style: TextStyle(color: Colors.indigo[300]))),
                          DataCell(
                            Center(
                              child: IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () =>
                                    _showDeleteQuizConfirmation(quiz),
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

  void _showDeleteQuizConfirmation(Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete quiz'),
          content: Text('Are you sure you want to delete ${quiz['name']}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await _database
                      .child('lecturers')
                      .child(quiz['lecturerId'])
                      .child('quizzes')
                      .child(quiz['id'])
                      .remove();
                  setState(() {
                    _allQuizzes.removeWhere((q) => q['id'] == quiz['id']);
                  });

                  if (context.mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Quiz deleted successfully')),
                    );
                  }

                  _loadAllQuizzes();
                } catch (e) {
                  // Show error message if deletion fails
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error deleting quiz: ${e.toString()}')),
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
