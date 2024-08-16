import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  FileUploadPageState createState() => FileUploadPageState();
}

class FileUploadPageState extends State<FileUploadPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String subject = '';
  String university = '';
  String degree = '';
  String year = '';
  String course = '';

  List<Map<dynamic, dynamic>> uploadedFiles = [];

  final List<String> defaultUniversities = ['SCE', 'ABC University', 'XYZ Institute'];
  final List<String> defaultDegrees = ['Software Engineer', 'Data Scientist', 'Product Manager'];
  final List<String> defaultYears = ['2022', '2023', '2024', '2025'];
  final List<String> defaultCourses = ['Hadas the Queen', 'Math 101', 'Programming Basics'];

  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUploadedFiles();
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

  Future<void> _fetchUploadedFiles() async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();
      if (lecturerId.isEmpty) {
        if (kDebugMode) {
          print('Lecturer ID is empty');
        }
        return;
      }

      DatabaseReference ref = FirebaseDatabase.instance.ref('files');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        List<Map<dynamic, dynamic>> files = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value['lecturerId'] == lecturerId) {
            files.add(value as Map<dynamic, dynamic>);
          }
        });

        setState(() {
          uploadedFiles = files;
        });
      } else {
        if (kDebugMode) {
          print('No files found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching files: $e');
      }
    }
  }

  Future<void> uploadFile() async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();
      if (lecturerId.isEmpty) {
        if (kDebugMode) {
          print('Lecturer ID is empty');
        }
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = file.path.split('/').last;

        // Upload file to your server
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://file-server-2-production.up.railway.app/upload'),
        );
        request.fields['lecturerId'] = lecturerId;
        request.fields['university'] = university;
        request.fields['degree'] = degree;
        request.fields['year'] = year;
        request.fields['course'] = course;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          // Store metadata in Realtime Database
          DatabaseReference ref = FirebaseDatabase.instance.ref('files').push();
          await ref.set({
            'lecturerId': lecturerId,
            'university': university,
            'degree': degree,
            'year': year,
            'course': course,
            'fileName': fileName,
            'fileUrl': fileName,
          });

          if (kDebugMode) {
            print('File uploaded and metadata stored successfully');
          }

          // Refresh the file list after uploading
          _fetchUploadedFiles();
        } else {
          if (kDebugMode) {
            print('File upload failed with status: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final encodedFileName = Uri.encodeComponent(fileName); // Encode the file name
      final response = await http.delete(Uri.parse('https://file-server-2-production.up.railway.app/files/$encodedFileName'));

      if (response.statusCode == 200) {
        // Remove file metadata from Realtime Database
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

        // Refresh the file list after deletion
        _fetchUploadedFiles();
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
        final encodedFileName = Uri.encodeComponent(fileName);

        final response = await http.get(
          Uri.parse('https://file-server-2-production.up.railway.app/files/$encodedFileName'),
        );

        if (response.statusCode == 200) {
          final directory = await getExternalStorageDirectory();
          final file = File('${directory!.path}/$fileName');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: uploadFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Upload File',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Uploaded Files:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // Adjust this value as needed
                    child: ListView.builder(
                      itemCount: uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = uploadedFiles[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              file['fileName'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.blue),
                                  onPressed: () => downloadFile(file['fileName']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteFile(file['fileName']),
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}
