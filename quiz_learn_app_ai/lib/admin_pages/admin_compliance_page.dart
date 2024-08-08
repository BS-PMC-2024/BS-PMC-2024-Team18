import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class AdminCompliancePage extends StatefulWidget {
  const AdminCompliancePage({super.key});

  @override
  AdminCompliancePageState createState() => AdminCompliancePageState();
}

class AdminCompliancePageState extends State<AdminCompliancePage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _complianceReports = [];

  @override
  void initState() {
    super.initState();
    _loadComplianceReports();
  }

  Future<void> _loadComplianceReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _complianceReports = await _firebaseService.loadComplianceReports();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading compliance reports: $e');
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
      appBar: AppBar(
        title: const Text('Compliance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplianceReports,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
Color(0xFFf2b39b), // Lighter #eb8671
Color(0xFFf19b86), // Lighter #ea7059
Color(0xFFf3a292), // Lighter #ef7d5d
Color(0xFFf8c18e), // Lighter #f8a567
Color(0xFFfcd797), // Lighter #fecc63
Color(0xFFcdd7a7), // Lighter #a7c484
Color(0xFF8fb8aa), // Lighter #5b9f8d
Color(0xFF73adbb), // Lighter #257b8c
Color(0xFFcc7699), // Lighter #ad3d75
Color(0xFF84d9db), // Lighter #1fd1d5
Color(0xFF85a8cf), // Lighter #2e7cbc
Color(0xFF8487ac), // Lighter #3d5488
Color(0xFFb7879c), // Lighter #99497f
Color(0xFF86cfd6), // Lighter #23b7c1
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildComplianceReportList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateReportDialog,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildComplianceReportList() {
    return ListView.builder(
      itemCount: _complianceReports.length,
      itemBuilder: (context, index) {
        final report = _complianceReports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ExpansionTile(
            title: Text('Report ID: ${report['id']}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReportDetail('Report Details', report['reportDetails']),
                    _buildReportDetail('Compliance Standards', report['complianceStandards']),
                    _buildReportDetail('Audit Date', report['auditDate']),
                    _buildReportDetail('User Consent Status', report['userConsentStatus']),
                    _buildReportDetail('Privacy Settings', report['privacySettings']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showDeleteConfirmation(report['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
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

  Widget _buildReportDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  void _showCreateReportDialog() {
    final reportDetailsController = TextEditingController();
    final complianceStandardsController = TextEditingController();
    final auditDateController = TextEditingController();
    final userConsentStatusController = TextEditingController();
    final privacySettingsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Compliance Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reportDetailsController,
                  decoration: const InputDecoration(labelText: 'Report Details'),
                ),
                TextField(
                  controller: complianceStandardsController,
                  decoration: const InputDecoration(labelText: 'Compliance Standards (e.g., GDPR, HIPAA)'),
                ),
                TextField(
                  controller: auditDateController,
                  decoration: const InputDecoration(labelText: 'Audit Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: userConsentStatusController,
                  decoration: const InputDecoration(labelText: 'User Consent Status'),
                ),
                TextField(
                  controller: privacySettingsController,
                  decoration: const InputDecoration(labelText: 'Privacy Settings'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () async {
                final reportData = {
                  'reportDetails': reportDetailsController.text,
                  'complianceStandards': complianceStandardsController.text,
                  'auditDate': auditDateController.text,
                  'userConsentStatus': userConsentStatusController.text,
                  'privacySettings': privacySettingsController.text,
                };
                await _firebaseService.createComplianceReport(reportData);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _loadComplianceReports(); // Refresh the list
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String reportId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _firebaseService.deleteComplianceReport(reportId);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                _loadComplianceReports(); // Refresh the list
              },
            ),
          ],
        );
      },
    );
  }
}
