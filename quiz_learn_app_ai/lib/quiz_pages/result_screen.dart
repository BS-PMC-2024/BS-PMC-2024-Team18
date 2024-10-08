import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';
import 'package:quiz_learn_app_ai/quiz_pages/quiz_ai_generated_feedback.dart';


import 'package:quiz_learn_app_ai/quiz_search/quiz_list_screen.dart';
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';
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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<UserDataToken> _users = [];
  @override
  void initState() {
    super.initState();
    _rightAnswers = widget.rightAnswers;
    _allQuestions = widget.allQuestions;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      List<UserDataToken> users = await _firebaseService.loadUsersWithTokens();
    _users.addAll(users.where((user) => 
  user.deviceToken != '' && user.userType == 'Lecturer'
));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // You might want to show a snackbar or some other error indication to the user here
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz results saved successfully')),
        );
        await sendMessageToLecturer(widget.quizData, points);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quiz results: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> sendMessageToLecturer(
      Map<dynamic, dynamic>? quizData, String points) async {
    User? user = _auth.currentUser;
    String? deviceToken;
    var lecturer =
        await _database.child('lecturers').child(quizData?['lecturerId']).get();
    String title = 'Quiz submission';
    String body =
        'A student ${user?.email} has completed the quiz: ${quizData?['name']} and scored $points points. Check out the detailed results in your dashboard!"';
    String data = quizData?['name'];
    try {
      for (UserDataToken user in _users) {
        if (user.id == lecturer.key) {
          deviceToken = user.deviceToken;
        }
      }
     
      if (mounted) {
         await PushNotifications().sendPushNotifications(
        deviceToken ?? '',
        body,
        title,
        data,
        context,
      );
      if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent to lecturer')),
        );

      }
      
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message to lecturer: ${e.toString()}'),
          ),
        );
      }
    }

    final DatabaseReference ref = _database
        .child('lecturers')
        .child(quizData?['lecturerId'])
        .child('notifications')
        .child('notificationFromStudent')
        .push();
    final String notificationId = ref.key!;
    final message = {
      'title': title,
      'body': body,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'senderId': user?.uid,
      'senderEmail': user?.email,
      'notificationId': notificationId,
    };
    try {
      await ref.set(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error saving notification to database: ${e.toString()}'),
          ),
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
              Color(0xFFf2b39b),
              Color(0xFFf19b86),
              Color(0xFFf3a292),
              Color(0xFFf8c18e),
              Color(0xFFfcd797),
              Color(0xFFcdd7a7),
              Color(0xFF8fb8aa),
              Color(0xFF73adbb),
              Color(0xFFcc7699),
              Color(0xFF84d9db),
              Color(0xFF85a8cf),
              Color(0xFF8487ac),
              Color(0xFFb7879c),
              Color(0xFF86cfd6),
            ],
          ),
        ),
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
            child:
                _buildQuestionsList(), // Make sure this is wrapped in Expanded
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
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You have $points points",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _allQuestions != null && _allQuestions!.isNotEmpty
              ? (_rightAnswers?.length ?? 0) / _allQuestions!.length
              : 0.0, // Default to 0.0 if there are no questions
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
        bool isCorrect =
            _rightAnswers?.contains(_allQuestions![index]['answer']) == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                color: Colors.black,
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
                  MaterialPageRoute(
                      builder: (context) => const QuizListScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Try again"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StudentHomePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Go Home"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Check if all required data is non-null and not empty
                if (widget.quizData != null &&
                    (_rightAnswers != null || widget.wrongAnswers != null) &&
                    (_rightAnswers!.isNotEmpty ||
                        widget.wrongAnswers!.isNotEmpty)) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => QuizAIGeneratedFeedback(
                        quizData: widget.quizData!,
                        rightAnswers: _rightAnswers!,
                        wrongAnswers: widget.wrongAnswers!,
                      ),
                    ),
                  );
                } else {
                  // Show an error message if any required data is null
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Unable to generate AI feedback due to missing data.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
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
