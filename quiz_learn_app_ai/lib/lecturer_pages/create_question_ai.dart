import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  String? _fileName;
  bool _isPDFMode = true;

  Future<void> _saveQuiz() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate questions before saving.')),
      );
      return;
    }

    // Show a dialog to enter the quiz name
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Quiz'),
        content: TextField(
          controller: _quizNameController,
          decoration: const InputDecoration(hintText: "Enter quiz name"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_quizNameController.text.isNotEmpty) {
                Navigator.of(context).pop();
                await _saveQuizToFirebase();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a quiz name')),
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
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final newQuizRef = _database.child('lecturers').child(user.uid).child('quizzes').push();
        await newQuizRef.set({
          'name': _quizNameController.text,
          'questions': _questions,
          'createdAt': ServerValue.timestamp,
        });
          if(mounted){
  ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully')),
        );
          }
      
      } else {
        throw Exception('User not logged in');
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
      });
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
        final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
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
        if(mounted){
   ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text from PDF: ${e.toString()}')),
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
      final questions = await _questionGenerator.generateQuestions(_textController.text);
      setState(() {
        _questions = questions;
        FocusScope.of(context).unfocus();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Questions with AI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('PDF'),
                  selected: _isPDFMode,
                  onSelected: (selected) {
                    setState(() {
                      _isPDFMode = selected;
                    });
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Text'),
                  selected: !_isPDFMode,
                  onSelected: (selected) {
                    setState(() {
                      _isPDFMode = !selected;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isPDFMode)
              ElevatedButton(
                onPressed: _isLoading ? null : _pickPDFAndExtractText,
                child: Text(_fileName ?? 'Upload PDF'),
              )
            else
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your text here...',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),
            if (_isPDFMode)
              TextField(
                controller: _textController,
                maxLines: 5,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'PDF text will appear here...',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateQuestions,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Questions'),
            ),
            const SizedBox(height: 16),
        
            ElevatedButton(
              onPressed: _isLoading ? null : _saveQuiz,
              child: const Text('Save Quiz'),
            ),
                 const SizedBox(height: 16),
            Expanded(
              child: _questions.isEmpty
                  ? const Center(child: Text('No questions generated yet'))
                  : ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${index + 1}: ${question['question'] ?? 'No question text'}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                if (question['options'] != null)
                                  ...List.generate(
                                    (question['options'] as List).length,
                                    (optionIndex) => Text(
                                      '${String.fromCharCode(65 + optionIndex)}. ${question['options'][optionIndex]}',
                                      style: TextStyle(
                                        color: question['options'][optionIndex] == question['answer']
                                            ? Colors.green
                                            : null,
                                      ),
                                    ),
                                  )
                                else
                                  const Text('No options available'),
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