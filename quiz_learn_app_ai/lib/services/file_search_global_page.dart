import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileSearchGlobalPage extends StatefulWidget {
  const FileSearchGlobalPage({super.key});

  @override
  FileSearchGlobalPageState createState() => FileSearchGlobalPageState();
}

class FileSearchGlobalPageState extends State<FileSearchGlobalPage> with SingleTickerProviderStateMixin {
  final List<String> defaultUniversities = ['SCE', 'ABC University', 'XYZ Institute'];
  final List<String> defaultDegrees = ['Software Engineer', 'Data Scientist', 'Product Manager'];
  final List<String> defaultYears = ['2022', '2023', '2024', '2025'];
  final List<String> defaultCourses = ['Hadas the Queen', 'Math 101', 'Programming Basics'];

  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  String university = 'All';
  String degree = 'All';
  String year = 'All';
  String course = 'All';
  List<Map<dynamic, dynamic>> materials = [];
   late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;


 @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> requestStoragePermission(BuildContext context) async {
    PermissionStatus storageStatus = await Permission.storage.status;
    PermissionStatus manageStorageStatus = await Permission.manageExternalStorage.status;

    if (storageStatus.isDenied || manageStorageStatus.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Storage permission is needed to download and open files.'),
            action: SnackBarAction(
              label: 'Grant Permission',
              onPressed: () async {
                await [
                  Permission.storage,
                  Permission.manageExternalStorage
                ].request();
              },
            ),
          ),
        );
      }
    } else if (storageStatus.isPermanentlyDenied || manageStorageStatus.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enable storage permission in settings.'),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> searchFiles(String university, String degree, String year, String course) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('files');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        List<Map<dynamic, dynamic>> files = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          bool matchUniversity = university == 'All' || value['university'] == university;
          bool matchDegree = degree == 'All' || value['degree'] == degree;
          bool matchYear = year == 'All' || value['year'] == year;
          bool matchCourse = course == 'All' || value['course'] == course;

          if (matchUniversity && matchDegree && matchYear && matchCourse) {
            files.add({
              'fileName': value['fileName'],
              'university': value['university'],
              'degree': value['degree'],
              'year': value['year'],
              'course': value['course']
            });
          }
        });

        setState(() {
          materials = files;
        });
      } else {
        if (kDebugMode) {
          print('No files found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching files: $e');
      }
    }
  }

  Future<void> downloadFile(String fileName) async {
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      if (mounted) {
        await requestStoragePermission(context);
        status = await Permission.manageExternalStorage.status;
      }
    }

    if (status.isGranted) {
      try {
        final encodedFileName = fileName;
        final response = await http.get(
          Uri.parse('https://file-server-2-production.up.railway.app/files/$encodedFileName'),
        );

        if (response.statusCode == 200) {
          final directory = await getExternalStorageDirectory();
          final decodedFileName = fileName;
          final file = File('${directory!.path}/$decodedFileName');
          await file.writeAsBytes(response.bodyBytes);

          OpenResult result = await OpenFile.open(file.path);
          if (kDebugMode) {
            print('Open File result: ${result.message}');
          }
        } else {
          if (kDebugMode) {
            print('Failed to download file: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error downloading file: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Storage permission not granted');
      }
    }
  }
  Widget _buildDropdown(String label, String selectedValue, List<String> options, ValueChanged<String?> onChanged, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[200]!, Colors.deepPurple[400]!], // Softer gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.white, // Keep the label text white
              fontWeight: FontWeight.bold,
              fontSize: 18, // Larger font size for better visibility
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.transparent,
          ),
          dropdownColor: Colors.deepPurple[50], // Softer dropdown background for contrast
          iconEnabledColor: Colors.white,
          value: selectedValue.isNotEmpty ? selectedValue : 'All',
          items: ['All', ...options, 'Add New'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.black87)), // Dark text for dropdown items
            );
          }).toList(),
          onChanged: (value) {
            if (value == 'Add New') {
              _showCustomInputDialog(label, controller);
            } else {
              setState(() {
                switch (label) {
                  case 'University':
                    university = value ?? 'All';
                    break;
                  case 'Degree':
                    degree = value ?? 'All';
                    break;
                  case 'Year':
                    year = value ?? 'All';
                    break;
                  case 'Course':
                    course = value ?? 'All';
                    break;
                }
              });
              onChanged(value);
            }
          },
        ),
      ),
    );
  }

  void _showCustomInputDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Add New $label', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  switch (label) {
                    case 'University':
                      if (!defaultUniversities.contains(controller.text) && controller.text.isNotEmpty) {
                        defaultUniversities.add(controller.text);
                        university = controller.text;
                      }
                      break;
                    case 'Degree':
                      if (!defaultDegrees.contains(controller.text) && controller.text.isNotEmpty) {
                        defaultDegrees.add(controller.text);
                        degree = controller.text;
                      }
                      break;
                    case 'Year':
                      if (!defaultYears.contains(controller.text) && controller.text.isNotEmpty) {
                        defaultYears.add(controller.text);
                        year = controller.text;
                      }
                      break;
                    case 'Course':
                      if (!defaultCourses.contains(controller.text) && controller.text.isNotEmpty) {
                        defaultCourses.add(controller.text);
                        course = controller.text;
                      }
                      break;
                  }
                  controller.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Search'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown('University', university, defaultUniversities, (value) {}, _universityController),
                _buildDropdown('Degree', degree, defaultDegrees, (value) {}, _degreeController),
                _buildDropdown('Year', year, defaultYears, (value) {}, _yearController),
                _buildDropdown('Course', course, defaultCourses, (value) {}, _courseController),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    searchFiles(university, degree, year, course);
                  },
                  child: const Text('Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final file = materials[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(file['fileName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'University: ${file['university']}\nDegree: ${file['degree']}\nYear: ${file['year']}\nCourse: ${file['course']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download, color: Colors.deepPurple),
                            onPressed: () {
                              downloadFile(file['fileName']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
