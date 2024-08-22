import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'question_generator.dart';

class CreateQuestionAI extends StatefulWidget {
  const CreateQuestionAI({super.key});

  @override
  CreateQuestionAIState createState() => CreateQuestionAIState();
}

class CreateQuestionAIState extends State<CreateQuestionAI> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _quizNameController = TextEditingController();
  final QuestionGenerator _questionGenerator = QuestionGenerator();
  final _database = FirebaseDatabase.instance.ref();
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedSubject = 'Other';
  final List<UserDataToken> _users = [];
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  String? _fileName;
  bool _isPDFMode = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      List<UserDataToken> users = await _firebaseService.loadUsersWithTokens();
      users.forEach((user) async {
        if (user.deviceToken != '' && user.userType == 'Student') {
          _users.add(user);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // You might want to show a snackbar or some other error indication to the user here
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _quizNameController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please generate questions before saving.')),
      );
      return;
    }

    // Show a dialog to enter the quiz name and subject
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Quiz'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                controller: _quizNameController,
                decoration: const InputDecoration(hintText: "Enter Quiz name"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Enter Quiz Subject',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Accounting',
                  'Aerospace Engineering',
                  'African Studies',
                  'Agricultural Science',
                  'American Studies',
                  'Anatomy',
                  'Anthropology',
                  'Applied Mathematics',
                  'Arabic',
                  'Archaeology',
                  'Architecture',
                  'Art History',
                  'Artificial Intelligence',
                  'Asian Studies',
                  'Astronomy',
                  'Astrophysics',
                  'Biochemistry',
                  'Bioengineering',
                  'Biology',
                  'Biomedical Engineering',
                  'Biotechnology',
                  'Business Administration',
                  'Chemical Engineering',
                  'Chemistry',
                  'Chinese',
                  'Civil Engineering',
                  'Classical Studies',
                  'Cognitive Science',
                  'Communication Studies',
                  'Computer Engineering',
                  'Computer Science',
                  'Criminal Justice',
                  'Cybersecurity',
                  'Data Science',
                  'Dentistry',
                  'Earth Sciences',
                  'Ecology',
                  'Economics',
                  'Education',
                  'Electrical Engineering',
                  'English Literature',
                  'Environmental Science',
                  'Epidemiology',
                  'European Studies',
                  'Film Studies',
                  'Finance',
                  'Fine Arts',
                  'Food Science',
                  'Forensic Science',
                  'French',
                  'Gender Studies',
                  'Genetics',
                  'Geography',
                  'Geology',
                  'German',
                  'Graphic Design',
                  'Greek',
                  'Health Sciences',
                  'History',
                  'Human Resources',
                  'Industrial Engineering',
                  'Information Systems',
                  'International Relations',
                  'Italian',
                  'Japanese',
                  'Journalism',
                  'Kinesiology',
                  'Latin',
                  'Law',
                  'Linguistics',
                  'Management',
                  'Marine Biology',
                  'Marketing',
                  'Materials Science',
                  'Mathematics',
                  'Mechanical Engineering',
                  'Media Studies',
                  'Medicine',
                  'Microbiology',
                  'Middle Eastern Studies',
                  'Music',
                  'Nanotechnology',
                  'Neuroscience',
                  'Nuclear Engineering',
                  'Nursing',
                  'Nutrition',
                  'Oceanography',
                  'Philosophy',
                  'Physics',
                  'Political Science',
                  'Psychology',
                  'Public Health',
                  'Religious Studies',
                  'Russian',
                  'Social Work',
                  'Sociology',
                  'Software Engineering',
                  'Spanish',
                  'Statistics',
                  'Sustainable Development',
                  'Theatre',
                  'Urban Planning',
                  'Veterinary Science',
                  'Zoology',
                  'Other'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue!;
                  });
                },
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
              if (_quizNameController.text.isNotEmpty &&
                  _selectedSubject.isNotEmpty) {
                Navigator.of(context).pop();
                await _saveQuizToFirebase();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter both quiz name and subject')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveQuizToFirebase() async {
    setState(() {
      FocusScope.of(context).unfocus();
      _isLoading = true;
    });

    try {
      await _firebaseService.saveQuizToFirebase(
        _quizNameController.text,
        _selectedSubject,
        _questions,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
        await sendNotificationToStudents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quiz: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendNotificationToStudents() async {
    User? lUser = FirebaseAuth.instance.currentUser;
    String quizName = _quizNameController.text;
    String description = _questions.last['description'] ?? 'No description';
    String subject = _selectedSubject;
    String title = 'New Quiz Available $quizName';
    String body = 'Quiz: $description Subject: $subject';
    String data = 'quiz';
    try {
      for (UserDataToken user in _users) {
        PushNotifications()
            .sendPushNotifications(user.deviceToken, body, title, data, null);
        await _database
            .child('students')
            .child(user.id)
            .child('notifications')
            .child('notificationFromLecturer')
            .child('AI Quiz')
            .push()
            .set({
          'quizName': quizName,
          'description': body,
          'type': data,
          'date': DateTime.now().toIso8601String(),
          'lecturerId': lUser?.uid,
          'lectureEmail': lUser?.email,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notifications: $e');
      }
    }
  }

  Future<void> _pickPDFAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
        _fileName = result.files.single.name;
      });

      try {
        final File file = File(result.files.single.path!);
        final PdfDocument document =
            PdfDocument(inputBytes: await file.readAsBytes());
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        String docText = extractor.extractText();

        // Truncate the text if it's too long
        if (docText.length > 4000) {
          docText = docText.substring(0, 4000);
        }

        setState(() {
          _textController.text = docText;
          _isLoading = false;
        });

        document.dispose();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error extracting text from PDF: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _generateQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions =
          await _questionGenerator.generateQuestions(_textController.text);
      setState(() {
        _questions = questions;
        FocusScope.of(context).unfocus();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildModeSelection(),
                          const SizedBox(height: 20),
                          _buildContentInput(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          _buildQuestionsList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Create Questions with AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeChip('PDF', _isPDFMode, (selected) {
            setState(() => _isPDFMode = selected);
          }),
          _buildModeChip('Text', !_isPDFMode, (selected) {
            setState(() => _isPDFMode = !selected);
          }),
        ],
      ),
    );
  }

  Widget _buildModeChip(
      String label, bool isSelected, Function(bool) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: Colors.blue[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.blue[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return _isPDFMode
        ? Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(_fileName ?? 'Upload PDF'),
                onPressed: _isLoading ? null : _pickPDFAndExtractText,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _textController,
                hintText: 'PDF text will appear here...',
                readOnly: true,
              ),
            ],
          )
        : _buildTextField(
            controller: _textController,
            hintText: 'Enter your text here...',
          );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: 5,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_isLoading ? null : Icons.create),
            label: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Generate Questions'),
            onPressed: _isLoading ? null : _generateQuestions,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Quiz'),
            onPressed: _isLoading ? null : _saveQuiz,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return _questions.isEmpty
        ? Center(
            child: Text(
              'No questions generated yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                // The first item is the description
                final description = _questions[_questions.length - 1]
                        ['description'] ??
                    'No description available';
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              } else {
                final question = _questions[
                    index - 1]; // Adjust index to account for description
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q$index: ${question['question'] ?? 'No question text'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (question['options'] != null)
                          ...List.generate(
                            (question['options'] as List).length,
                            (optionIndex) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${String.fromCharCode(65 + optionIndex)}. ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${question['options'][optionIndex]}',
                                      style: TextStyle(
                                        color: question['options']
                                                    [optionIndex] ==
                                                question['answer']
                                            ? Colors.green
                                            : null,
                                        fontWeight: question['options']
                                                    [optionIndex] ==
                                                question['answer']
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (question['options'][optionIndex] ==
                                      question['answer'])
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                ],
                              ),
                            ),
                          )
                        else
                          const Text(
                            'No options available',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
  }
}
