import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/quiz_pages/quiz_ai_generated_feedback.dart';

import 'package:quiz_learn_app_ai/quiz_pages/widgets/background_decoration.dart';

import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? quizData;
  final List<String>? rightAnswers;
  final List<String>? wrongAnswers;
  final List<Map<dynamic, dynamic>> allQuestions;

  const ResultScreen({
    super.key,
    this.quizData,
    this.rightAnswers,
    this.wrongAnswers,
    required this.allQuestions,
  });

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  List<String>? _rightAnswers;
  List<Map<dynamic, dynamic>>? _allQuestions;
final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _allQuestions = widget.allQuestions;

  }

 Future<void> _saveResults() async {
    try {
      await _firebaseService.saveQuizResults(
        widget.quizData?['id'],
        widget.quizData?['name'],
        _rightAnswers,
        widget.wrongAnswers,
        points,
        widget.allQuestions,
      );
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz results saved successfully')),
      );}
     
    } catch (e) {
       if(mounted){  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz results: ${e.toString()}')),
      );}
    
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: BackgroundDecoration(
    
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    ),
   
  );
}

Widget _buildAppBar() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text(
          '${_rightAnswers?.length ?? 0} out of ${_allQuestions?.length ?? 0} are correct',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildContent() {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        _buildCongratulationsSection(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildQuestionsList(),
        ),
        _buildActionButtons(),
      ],
    ),
  );
}

Widget _buildCongratulationsSection() {
  return Column(
    children: [
      const Text(
        "Congratulations!",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "You have $points points",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 16),
      LinearProgressIndicator(
        value: (_rightAnswers?.length ?? 0) / (_allQuestions?.length ?? 1),
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
      ),
    ],
  );
}

Widget _buildQuestionsList() {
  return ListView.builder(
    itemCount: _allQuestions?.length ?? 0,
    itemBuilder: (_, index) {
      bool isCorrect = _rightAnswers?.contains(_allQuestions![index]['answer']) == true;
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: isCorrect ? Colors.green : Colors.red,
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Question ${index + 1}: ${_allQuestions![index]['question']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            isCorrect ? 'Correct' : 'Wrong',
            style: TextStyle(
              color: isCorrect ? Colors.green[300] : Colors.red[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildActionButtons() {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizListScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Try again"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Go Home"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => QuizAIGeneratedFeedback(
                quizData: widget.quizData,
                rightAnswers: _rightAnswers,
                wrongAnswers: widget.wrongAnswers,
              )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("AI feedback"),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _saveResults,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ],
    ),
  );
}

  String get points {
    var points = (_rightAnswers!.length / _allQuestions!.length) * 100;
    return points.toStringAsFixed(2);
  }
}
