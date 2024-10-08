//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/submitted_quiz_details.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

//import '../admin_pages/admin_user_management_page.dart';

class LecturerQuizOverview extends StatefulWidget {
  final String quizId;
  const LecturerQuizOverview({super.key, required this.quizId});

  @override
  LecturerQuizOverviewState createState() => LecturerQuizOverviewState();
}

class LecturerQuizOverviewState extends State<LecturerQuizOverview> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _students = await _firebaseService.loadPerformedQuizUsers(widget.quizId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users data: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildStudentList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildStudentCard(_students[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToSubmittedQuizDetails(student),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      student['name'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  _buildScoreChip(student['points']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy')
                        .format(DateTime.parse(student['date'])),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressIndicator(student),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSubmittedQuizDetails(student),
                  icon: const Icon(Icons.draw_rounded),
                  label: const Text('Write Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

  Widget _buildScoreChip(dynamic points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Score: $points',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> student) {
    final totalQuestions = student['questionCount']  ?? 0;
    final correctAnswers = student['rightAnswers']?.length ?? 0;
    final progress = totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          '$correctAnswers / $totalQuestions correct',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
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
          const Text(
            'My Quizzes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSubmittedQuizDetails(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmittedQuizDetail(
          student: student,
        ),
      ),
    );
  }
}
