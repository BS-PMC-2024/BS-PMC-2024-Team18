import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class AdminQuizReportsPage extends StatefulWidget {
  const AdminQuizReportsPage({super.key});

  @override
  AdminQuizReportsPageState createState() => AdminQuizReportsPageState();
}

class AdminQuizReportsPageState extends State<AdminQuizReportsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _quizReports = [];
  List<Map<String, dynamic>> _allQuizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _quizReports = await _firebaseService.loadAllQuizReports();
      _allQuizzes = await _firebaseService.loadAllQuizzes();
      if (kDebugMode) {
        print('Loaded reports: $_quizReports');
        print('Loaded quizzes: $_allQuizzes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteQuizReport(String quizId, String reportId) async {
    final confirm = await _showConfirmationDialog(
      context,
      'Delete Report',
      'Are you sure you want to delete this report?',
    );
    if (confirm) {
      try {
        await _firebaseService.deleteQuizReport(quizId, reportId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadAllData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteQuiz(String lecturerId, String quizId) async {
    final confirm = await _showConfirmationDialog(
      context,
      'Delete Quiz',
      'Are you sure you want to delete this quiz and all related reports?',
    );
    if (confirm) {
      try {
        await _firebaseService.deleteQuiz2(lecturerId, quizId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadAllData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting quiz: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Quiz Reports'),
        centerTitle: true,
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizReports.isEmpty
                ? const Center(child: Text('No reports found.'))
                : ListView.builder(
                    itemCount: _quizReports.length,
                    itemBuilder: (context, index) {
                      final report = _quizReports[index];
                      final quiz = _allQuizzes.firstWhere(
                        (quiz) => quiz['id'] == report['quizId'],
                        orElse: () => {},
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz['name'] ?? 'Unnamed Quiz',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subject: ${quiz['subject'] ?? 'No Subject'}',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lecturer: ${quiz['lecturer'] ?? 'Unknown Lecturer'}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Description: ${quiz['description']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Report: ${report['reportDetails'] ?? 'No details'}',
                                style: TextStyle(fontSize: 14, color: Colors.red[800]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Reported by: ${report['reportedBy'] ?? 'Unknown'}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                 Row(
  children: [
    IconButton(
      icon: const Icon(Icons.report_gmailerrorred, color: Colors.orange),
      onPressed: () => _deleteQuizReport(report['quizId'], report['reportId']),
      tooltip: 'Remove Report', // Changed tooltip for clarity
    ),
    IconButton(
      icon: const Icon(Icons.delete_sweep, color: Colors.purple),
      onPressed: () => _deleteQuiz(quiz['lecturerId'], report['quizId']),
      tooltip: 'Erase Quiz and All Reports', // Changed tooltip for clarity
    ),
  ],
),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}