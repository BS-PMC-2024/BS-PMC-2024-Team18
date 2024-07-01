import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizDetailsPage extends StatefulWidget {
  final String quizId;
  final String initialQuizName;

  const QuizDetailsPage({
    super.key,
    required this.quizId,
    required this.initialQuizName,
  });

  @override
  QuizDetailsPageState createState() => QuizDetailsPageState();
}

class QuizDetailsPageState extends State<QuizDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  late TextEditingController _quizNameController;
  List<Map<dynamic, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quizNameController = TextEditingController(text: widget.initialQuizName);
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _database
            .child('lecturers')
            .child(user.uid)
            .child('quizzes')
            .child(widget.quizId)
            .get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _questions = List<Map<dynamic, dynamic>>.from(data['questions']);
          });
        }
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quiz details: ${e.toString()}')),
      );
      if (kDebugMode) {
        print("Error loading quiz details: ${e.toString()}");
      }
      }
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _database
            .child('lecturers')
            .child(user.uid)
            .child('quizzes')
            .child(widget.quizId)
            .update({
          'name': _quizNameController.text,
          'questions': _questions,
        });
 if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
  
 }
      
      }
    } catch (e) {
      if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz: ${e.toString()}')),
      );

      }
     
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final question = _questions[index];
        final TextEditingController questionController = TextEditingController(text: question['question']);
        final List<TextEditingController> optionControllers = 
          (question['options'] as List).map((option) => TextEditingController(text: option)).toList();
        final TextEditingController answerController = TextEditingController(text: question['answer']);

        return AlertDialog(
          title: Text('Edit Question ${index + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 10),
                ...List.generate(optionControllers.length, (i) => 
                  TextField(
                    controller: optionControllers[i],
                    decoration: InputDecoration(labelText: 'Option ${String.fromCharCode(65 + i)}'),
                  )
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'Correct Answer'),
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
                setState(() {
                  _questions[index] = {
                    'question': questionController.text,
                    'options': optionControllers.map((controller) => controller.text).toList(),
                    'answer': answerController.text,
                  };
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Quiz' : 'Quiz Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveQuiz();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _quizNameController,
                    decoration: const InputDecoration(labelText: 'Quiz Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  const Text('Questions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return Card(
                        child: ListTile(
                          title: Text(question['question']),
                          subtitle: Text('Options: ${question['options'].join(", ")}'),
                          trailing: _isEditing
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _quizNameController.dispose();
    super.dispose();
  }
}