import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  CreateQuizPageState createState() => CreateQuizPageState();
}

class CreateQuizPageState extends State<CreateQuizPage> {
  final List<UserDataToken> _users = [];
  final _database = FirebaseDatabase.instance.ref();
  final TextEditingController _quizNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedSubject = 'Other';
  final FirebaseService _firebaseService = FirebaseService();
  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      List<UserDataToken> users = await _firebaseService.loadUsersWithTokens();
    for (final user in users) {
  if (user.deviceToken != '' && user.userType == 'Student') {
    _users.add(user);
  }
}
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // You might want to show a snackbar or some other error indication to the user here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _quizNameController,
              decoration: const InputDecoration(labelText: 'Quiz Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
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
            const SizedBox(height: 20),
            Text(
              'Questions:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            const SizedBox(height: 10),
            ..._questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionCard(question, index);
            }),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQuiz,
              child: const Text('Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${index + 1}: ${question['question']}'),
            const SizedBox(height: 8),
            ...(question['options'] as List<dynamic>)
                .asMap()
                .entries
                .map((entry) {
              final int optionIndex = entry.key;
              final String option = entry.value as String;
              return Text('${String.fromCharCode(65 + optionIndex)}. $option');
            }),
            Text('Correct Answer: ${question['answer']}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editQuestion(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteQuestion(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(existingQuestion: _questions[index], index: index);
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _showQuestionDialog(
      {Map<String, dynamic>? existingQuestion, int? index}) {
    final questionController =
        TextEditingController(text: existingQuestion?['question']);
    final optionControllers = List.generate(
      4,
      (i) =>
          TextEditingController(text: existingQuestion?['options']?[i] ?? ''),
    );
    final answerController =
        TextEditingController(text: existingQuestion?['answer']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(existingQuestion == null ? 'Add Question' : 'Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                ...List.generate(
                    4,
                    (i) => TextField(
                          controller: optionControllers[i],
                          decoration: InputDecoration(
                              labelText:
                                  'Option ${String.fromCharCode(65 + i)}'),
                        )),
                TextField(
                  controller: answerController,
                  decoration:
                      const InputDecoration(labelText: 'Correct Answer'),
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
              onPressed: () {
                final newQuestion = {
                  'question': questionController.text,
                  'options': optionControllers.map((c) => c.text).toList(),
                  'answer': answerController.text,
                };
                setState(() {
                  if (index != null) {
                    _questions[index] = newQuestion;
                  } else {
                    _questions.add(newQuestion);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveQuiz() async {
    if (_quizNameController.text.isEmpty ||
        _selectedSubject.isEmpty ||
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter a quiz name, subject, and add at least one question')),
      );
      return;
    }

    try {
      // Add the description to the last question
      final List<Map<String, dynamic>> questionsWithDescription =
          List.from(_questions)
            ..add({
              'description': _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : '',
            });

      await _firebaseService.saveQuizToFirebase(
        _quizNameController.text,
        _selectedSubject,
        questionsWithDescription,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
        await sendNotificationToStudents();
        if(mounted){
            Navigator.of(context).pop();
        }
      
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quiz: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> sendNotificationToStudents() async {
    User? lUser = FirebaseAuth.instance.currentUser;
    String quizName = _quizNameController.text;
    String description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : '';
    String subject = _selectedSubject;
    String title = 'New Quiz Available $quizName';
    String body = 'Quiz: $description\nSubject: $subject';
    String data = 'quiz';
    try {
      for (UserDataToken user in _users) {
        PushNotifications()
            .sendPushNotifications(user.deviceToken, body, title, data, null);
        final DatabaseReference ref = _database
            .child('students')
            .child(user.id)
            .child('notifications')
            .child('notificationFromLecturer')
            .push();
        final String notificationId = ref.key!;    
        final message = {    
          'quizName': quizName,
          'description': body,
          'type': data,
          'date': DateTime.now().toIso8601String(),
          'lecturerId': lUser?.uid,
          'lectureEmail': lUser?.email,
          'notificationId': notificationId,
        };
        await ref.set(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notifications: $e');
      }
    }
  }
}

class StudentsData {
  final String id;
  final String email;
  final String userType;
  final String deviceToken;
  final List<String> courses;

  StudentsData({
    required this.id,
    required this.email,
    required this.userType,
    required this.deviceToken,
    required this.courses,
  });
}
