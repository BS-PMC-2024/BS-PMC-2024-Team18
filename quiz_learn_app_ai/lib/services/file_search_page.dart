import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// Assuming you have a FirebaseService class with the getLecturerId() method.
import 'firebase_service.dart'; // Update with the actual import path.

class FileSearchPage extends StatefulWidget {
  const FileSearchPage({super.key});

  @override
  FileSearchPageState createState() => FileSearchPageState();
}

class FileSearchPageState extends State<FileSearchPage> {
  final List<String> defaultUniversities = ['SCE', 'ABC University', 'XYZ Institute'];
  final List<String> defaultDegrees = ['Software Engineer', 'Data Scientist', 'Product Manager'];
  final List<String> defaultYears = ['2022', '2023', '2024', '2025'];
  final List<String> defaultCourses = ['Hadas the Queen', 'Math 101', 'Programming Basics'];

  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  String university = '';
  String degree = '';
  String year = '';
  String course = '';
  List<Map<dynamic, dynamic>> materials = [];

  final FirebaseService _firebaseService = FirebaseService(); // Replace with actual instance

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

  Future<void> searchFiles(String lecturerId, String university, String degree, String year, String course) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('files');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        List<Map<dynamic, dynamic>> files = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if ((value['lecturerId'] == lecturerId) &&
              (university.isEmpty || value['university'] == university) &&
              (degree.isEmpty || value['degree'] == degree) &&
              (year.isEmpty || value['year'] == year) &&
              (course.isEmpty || value['course'] == course)) {
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
          if (kDebugMode) {
            print('File downloaded to ${file.path}');
          }

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

  Future<void> deleteFile(String fileName) async {
    try {
      final encodedFileName = fileName;
      final response = await http.delete(Uri.parse('https://file-server-2-production.up.railway.app/files/$encodedFileName'));

      if (response.statusCode == 200) {
        DatabaseReference ref = FirebaseDatabase.instance.ref('files');
        final snapshot = await ref.get();
        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) async {
            if (value['fileName'] == fileName) {
              await ref.child(key).remove();
            }
          });
        }

        if (kDebugMode) {
          print('File deleted successfully');
        }

        String lecturerId = await _firebaseService.getLecturerId();
        if (lecturerId.isEmpty) {
          if (kDebugMode) {
            print('Lecturer ID is empty');
          }
          return;
        }

        searchFiles(lecturerId, university, degree, year, course);
      } else {
        if (kDebugMode) {
          print('Failed to delete file: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _firebaseService.getLecturerId().then((lecturerId) {
      if (lecturerId.isNotEmpty) {
        searchFiles(lecturerId, university, degree, year, course);
      } else {
        if (kDebugMode) {
          print('Lecturer ID is empty');
        }
      }
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Files'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown('University', university, defaultUniversities, (value) {
              setState(() {
                university = value ?? '';
              });
            }, _universityController),
            _buildDropdown('Degree', degree, defaultDegrees, (value) {
              setState(() {
                degree = value ?? '';
              });
            }, _degreeController),
            _buildDropdown('Year', year, defaultYears, (value) {
              setState(() {
                year = value ?? '';
              });
            }, _yearController),
            _buildDropdown('Course', course, defaultCourses, (value) {
              setState(() {
                course = value ?? '';
              });
            }, _courseController),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String lecturerId = await _firebaseService.getLecturerId();
                if (lecturerId.isEmpty) {
                  if (kDebugMode) {
                    print('Lecturer ID is empty');
                  }
                  return;
                }
                searchFiles(lecturerId, university, degree, year, course);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Search', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final file = materials[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        file['fileName'] ?? 'No file name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${file['university']} - ${file['degree']} - ${file['year']} - ${file['course']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.teal),
                            onPressed: () => downloadFile(file['fileName'] ?? ''),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteFile(file['fileName'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String selectedValue, List<String> options, ValueChanged<String?> onChanged, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.teal),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: selectedValue.isNotEmpty ? selectedValue : null,
          items: [...options, 'Add New'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (value == 'Add New') {
              _showCustomInputDialog(label, controller);
            } else {
              setState(() {
                switch (label) {
                  case 'University':
                    university = value ?? '';
                    break;
                  case 'Degree':
                    degree = value ?? '';
                    break;
                  case 'Year':
                    year = value ?? '';
                    break;
                  case 'Course':
                    course = value ?? '';
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
          title: Text('Add New $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter $label',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  switch (label) {
                    case 'University':
                      defaultUniversities.add(controller.text);
                      university = controller.text;
                      break;
                    case 'Degree':
                      defaultDegrees.add(controller.text);
                      degree = controller.text;
                      break;
                    case 'Year':
                      defaultYears.add(controller.text);
                      year = controller.text;
                      break;
                    case 'Course':
                      defaultCourses.add(controller.text);
                      course = controller.text;
                      break;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }}