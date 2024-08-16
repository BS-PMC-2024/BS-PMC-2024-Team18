import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class AdminPlatformReportsPage extends StatefulWidget {
  const AdminPlatformReportsPage({Key? key}) : super(key: key);

  @override
  _AdminPlatformReportsPageState createState() => _AdminPlatformReportsPageState();
}

class _AdminPlatformReportsPageState extends State<AdminPlatformReportsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      Map<String, dynamic> data = await _firebaseService.getPlatformReportData();
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading report data: $e');
      setState(() {
        _isLoading = false;
        _reportData = {'error': 'Failed to load data. Please check your internet connection and try again.'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData.containsKey('error')
              ? Center(child: Text(_reportData['error']))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportSection('User Statistics', [
                        'Total Users: ${_reportData['totalUsers']}',
                        'New Users Today: ${_reportData['newUsersToday']}',
                        'Active Users (Last 7 Days): ${_reportData['activeUsers7Days']}',
                      ]),
                      _buildReportSection('Quiz Statistics', [
                        'Total Quizzes: ${_reportData['totalQuizzes']}',
                        'Quizzes Created Today: ${_reportData['quizzesCreatedToday']}',
                        'Average Quiz Score: ${_reportData['averageQuizScore']}',
                      ]),
                      _buildReportSection('Compliance Reports', [
                        'Total Compliance Reports: ${_reportData['totalComplianceReports']}',
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReportSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(item),
                )),
          ],
        ),
      ),
    );
  }
}