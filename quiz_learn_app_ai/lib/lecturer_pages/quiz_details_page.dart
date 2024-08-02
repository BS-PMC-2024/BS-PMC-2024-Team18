import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:intl/intl.dart';


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
 late DateTime _startTime;
  late DateTime _endTime;


  @override
  void initState() {
    super.initState();
    _quizNameController = TextEditingController(text: widget.initialQuizName);
    _descriptionController = TextEditingController();
       _startTime = DateTime.now();
    _endTime = DateTime.now().add(const Duration(hours: 1));
    _loadQuizDetails();
  }

  // Function to select date and time
Future<void> _selectDateTime(DateTime initialDateTime, Function(DateTime) onDateTimeSelected) async {
  // Use a local variable for context to avoid using the context directly in async operations
  final BuildContext localContext = context;

  final DateTime? selectedDateTime = await showDatePicker(
    context: localContext,
    initialDate: initialDateTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (selectedDateTime != null&& context.mounted) {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: localContext,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (selectedTime != null) {
      final DateTime newDateTime = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      if (mounted) {
        onDateTimeSelected(newDateTime);
      }
    }
  }
}

  // Add date time fields to the widget tree
  Widget _buildStartTimeField() {
    return TextFormField(
      controller: TextEditingController(text: DateFormat.yMd().add_jm().format(_startTime)),
      decoration: InputDecoration(
        labelText: 'Start Time',
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
      readOnly: true,
      onTap: () {
        _selectDateTime(_startTime, (selectedDateTime) {
          setState(() {
            _startTime = selectedDateTime;
          });
        });
      },
    );
  }

  Widget _buildEndTimeField() {
    return TextFormField(
      controller: TextEditingController(text: DateFormat.yMd().add_jm().format(_endTime)),
      decoration: InputDecoration(
        labelText: 'End Time',
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
      readOnly: true,
      onTap: () {
        _selectDateTime(_endTime, (selectedDateTime) {
          setState(() {
            _endTime = selectedDateTime;
          });
        });
      },
    );
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
          
          // Parse and set the start and end times
          _startTime = DateTime.parse(quizData['startTime'] ?? DateTime.now().toIso8601String());
          _endTime = DateTime.parse(quizData['endTime'] ?? DateTime.now().toIso8601String());
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
  // Show loading indicator
  setState(() {
    _isLoading = true;
  });

  try {
    // Call the service to update the quiz with new data
    await _firebaseService.updateQuiz(
      widget.quizId,
      _quizNameController.text,
      _questions,
      _descriptionController.text,
      _startTime.toIso8601String(), // Save start time
      _endTime.toIso8601String(),   // Save end time
    );

    // Show success message if update is successful
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz saved successfully')),
      );
    }
  } catch (e) {
    // Show error message if there is an issue with the update
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz: ${e.toString()}')),
      );
      if (kDebugMode) {
        print('Error saving quiz: ${e.toString()}'); // Print error details in debug mode
      }
    }
  } finally {
    // Hide loading indicator and reset editing state
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
        // Title of the dialog indicating which question is being edited
        title: Text('Edit Question ${index + 1}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text field for editing the question
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 10),
              // Text fields for editing the options, dynamically generated based on the number of options
              ...List.generate(optionControllers.length, (i) => 
                TextField(
                  controller: optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${String.fromCharCode(65 + i)}'),
                )
              ),
              const SizedBox(height: 10),
              // Text field for editing the correct answer
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel button to close the dialog without saving changes
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Save button to update the question with the new values
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
      decoration: const BoxDecoration(
        gradient:LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFeb8671), // #eb8671
          Color(0xFFea7059), // #ea7059
          Color(0xFFef7d5d), // #ef7d5d
          Color(0xFFf8a567), // #f8a567
          Color(0xFFfecc63), // #fecc63
          Color(0xFFa7c484), // #a7c484
          Color(0xFF5b9f8d), // #5b9f8d
          Color(0xFF257b8c), // #257b8c
          Color(0xFFad3d75), // #ad3d75
          Color(0xFF1fd1d5), // #1fd1d5
          Color(0xFF2e7cbc), // #2e7cbc
          Color(0xFF3d5488), // #3d5488
          Color(0xFF99497f), // #99497f
          Color(0xFF23b7c1), // #23b7c1
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
        // Back button to navigate to the previous screen
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Title that changes based on whether the user is editing or viewing details
        Text(
          _isEditing ? 'Edit Quiz' : 'Quiz Details',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Button to toggle between edit and save modes
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
          onPressed: () {
            if (_isEditing) {
              // Call the function to update the quiz when in edit mode
              _updateQuiz();
            } else {
              // Switch to edit mode
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
                    _buildStartTimeField(), // Start time field
                    const SizedBox(height: 10),
                    _buildEndTimeField(), // End time field
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