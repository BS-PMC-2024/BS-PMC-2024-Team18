import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  FileUploadPageState createState() => FileUploadPageState();
}

class FileUploadPageState extends State<FileUploadPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String subject = '';
  String university = '';
  String year = '';
  List<String> materials = [];

  @override
  void initState() {
    super.initState();
    fetchStudyMaterials();
  }

  Future<void> uploadFile() async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        var request = http.MultipartRequest('POST', Uri.parse('https://file-server-w2vy.onrender.com/upload'));
        request.fields['userId'] = lecturerId;
        request.fields['subject'] = subject;
        request.fields['university'] = university;
        request.fields['year'] = year;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('File uploaded successfully');
          }
          fetchStudyMaterials();
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

  Future<void> fetchStudyMaterials() async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();
      final response = await http.get(Uri.parse('https://file-server-w2vy.onrender.com/list-materials/$lecturerId'));

      if (response.statusCode == 200) {
        setState(() {
          materials = List<String>.from(json.decode(response.body));
        });
      } else {
        if (kDebugMode) {
          print('Failed to load study materials: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching study materials: $e');
      }
    }
  }

  Future<void> downloadFile(String filePath) async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();
      final response = await http.get(Uri.parse('https://file-server-w2vy.onrender.com/download/$lecturerId/$filePath'));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${filePath.split('/').last}');
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('File downloaded to ${file.path}');
        }
        OpenFile.open(file.path); // Open the file immediately
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
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final lecturerId = await _firebaseService.getLecturerId();
      final response = await http.delete(Uri.parse('https://file-server-w2vy.onrender.com/delete/$lecturerId/$filePath'));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('File deleted successfully');
        }
        fetchStudyMaterials();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchMaterialsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
              onChanged: (value) => subject = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'University'),
              onChanged: (value) => university = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Year'),
              onChanged: (value) => year = value,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Upload PDF'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(materials[index]),
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.teal),
                            onPressed: () => downloadFile(materials[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteFile(materials[index]),
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
}

class SearchMaterialsPage extends StatefulWidget {
  const SearchMaterialsPage({super.key});

  @override
  SearchMaterialsPageState createState() => SearchMaterialsPageState();
}

class SearchMaterialsPageState extends State<SearchMaterialsPage> {
  String subject = '';
  String university = '';
  String year = '';
  List<String> searchResults = [];

  Future<void> searchMaterials() async {
    try {
      final response = await http.get(Uri.parse(
          'https://file-server-w2vy.onrender.com/search-materials?subject=$subject&university=$university&year=$year'));

      if (response.statusCode == 200) {
        setState(() {
          searchResults = List<String>.from(json.decode(response.body));
        });
      } else {
        if (kDebugMode) {
          print('Failed to search materials: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching materials: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Materials'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
              onChanged: (value) => subject = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'University'),
              onChanged: (value) => university = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Year'),
              onChanged: (value) => year = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: searchMaterials,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(searchResults[index]),
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
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
}