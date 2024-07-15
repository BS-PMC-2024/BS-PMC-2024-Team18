import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

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
   final FirebaseService _firebaseService = FirebaseService();
  late TextEditingController _quizNameController;
  late TextEditingController _descriptionController;
  List<Map<dynamic, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quizNameController = TextEditingController(text: widget.initialQuizName);
    _descriptionController = TextEditingController();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final quizData = await _firebaseService.loadQuizDetails(widget.quizId);
    
    if (quizData != null) {
      setState(() {
        _quizNameController.text = quizData['name'] ?? '';
        _questions = List<Map<dynamic, dynamic>>.from(quizData['questions'] ?? []);
        
        // Update description if available
        if (_questions.isNotEmpty && _questions.last.containsKey('description')) {
          _descriptionController.text = _questions.last['description'];
        } else {
          _descriptionController.text = quizData['description'] ?? '';
        }
      });
    }
  } catch (e) {
    if (mounted) {
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

 Future<void> _updateQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.updateQuiz(
        widget.quizId,
        _quizNameController.text,
        _questions,
        _descriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
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
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.blue[400]!],
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildQuizContent(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Title
        Text(
          _isEditing ? 'Edit Quiz' : 'Quiz Details',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Edit/Save button
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
          onPressed: () {
            if (_isEditing) {
              _updateQuiz();
            } else {
              setState(() {
                _isEditing = true;
              });
            }
          },
        ),
      ],
    ),
  );
}


Widget _buildQuizContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuizNameField(),
        const SizedBox(height: 20),
        _buildDescriptionField(), // New description field
        const SizedBox(height: 10),
        Text(
          'Questions:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length -1,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return _buildQuestionCard(question, index);
          },
        ),
      ],
    ),
  );
}


Widget _buildQuizNameField() {
  return TextFormField(
    controller: _quizNameController,
    decoration: InputDecoration(
      labelText: 'Quiz Name',
      enabled: _isEditing,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
    ),
    style: const TextStyle(fontSize: 18),
  );
}

// Edit starts here
Widget _buildDescriptionField() {
  return TextFormField(
    controller: _descriptionController, // Make sure you define this controller
    decoration: InputDecoration(
      labelText: 'Quiz Description',
      enabled: _isEditing,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
    ),
    style: const TextStyle(fontSize: 18),
    maxLines: null, // Allow the description to be multiple lines
  );
}
// Edit ends here

Widget _buildQuestionCard(Map<dynamic, dynamic> question, int index) {
  // Cast the Map<dynamic, dynamic> to Map<String, dynamic>
  final Map<String, dynamic> typedQuestion = Map<String, dynamic>.from(question);
  final String correctAnswer = typedQuestion['answer'] as String? ?? '';
  
  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          const SizedBox(height: 8),
          Text(
            typedQuestion['question'] as String? ?? 'No question text',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'Options:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (typedQuestion['options'] != null)
            ...(typedQuestion['options'] as List<dynamic>).asMap().entries.map((entry) {
              final int optionIndex = entry.key;
              final String option = entry.value as String;
              final bool isCorrectAnswer = option == correctAnswer;
              
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Text(
                      '${String.fromCharCode(65 + optionIndex)}. ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCorrectAnswer ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCorrectAnswer ? Colors.green : Colors.black,
                          fontWeight: isCorrectAnswer ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrectAnswer)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ),
              );
            })
          else
            const Text('No options available', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          if (_isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue[800]),
                  onPressed: () => _editQuestion(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(index),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}



  @override
  void dispose() {
    _quizNameController.dispose();
    _descriptionController.dispose(); // Dispose of the description controller
    super.dispose();
  }
}