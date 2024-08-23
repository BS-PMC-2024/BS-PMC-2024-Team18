import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  AdminSettingsPageState createState() => AdminSettingsPageState();
}

class AdminSettingsPageState extends State<AdminSettingsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _firebaseService.getAdminSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      await _firebaseService.updateAdminSetting(key, value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setting updated successfully')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating setting: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update setting')),
      );
    }
  }

  Widget _buildSettingItem(String title, String description, Widget control) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: control,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ExpansionTile(
                  title: const Text('User Management'),
                  children: [
                    _buildSettingItem(
                      'Maximum Login Attempts',
                      'Set the maximum number of failed login attempts before account lockout',
                      DropdownButton<int>(
                        value: _settings['maxLoginAttempts'] ?? 5,
                        items: [3, 5, 10].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          await _updateSetting('maxLoginAttempts', value);
                          setState(() {
                            _settings['maxLoginAttempts'] = value;
                          });
                        },
                      ),
                    ),
                    _buildSettingItem(
                      'Lockout Duration (minutes)',
                      'Set the duration of account lockout after exceeding maximum login attempts',
                      DropdownButton<int>(
                        value: _settings['lockoutDurationMinutes'] ?? 30,
                        items: [10, 30, 60, 120].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          await _updateSetting('lockoutDurationMinutes', value);
                          setState(() {
                            _settings['lockoutDurationMinutes'] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}