import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/create_quiz_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_quiz_overview.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/quiz_details_page.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart'; // Add this import for date formatting

class MyQuizzesPage extends StatefulWidget {
  const MyQuizzesPage({super.key});

  @override
  MyQuizzesPageState createState() => MyQuizzesPageState();
}

class MyQuizzesPageState extends State<MyQuizzesPage> {
  // List to store quizzes
  List<Map<String, dynamic>> _quizzes = [];
  // Boolean to track loading state
  bool _isLoading = true;
  // Firebase service instance
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadQuizzes(); // Load quizzes when the page initializes
  }

  // Method to load quizzes from the Firebase service
  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true; // Set loading state to true while fetching data
    });

    try {
      _quizzes = await _firebaseService.loadQuizzes(); // Fetch quizzes
    } catch (e) {
      // Show error message if loading quizzes fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after fetching data
      });
    }
  }

  // Method to delete a quiz by its ID
  Future<void> _deleteQuiz(String quizId) async {
    try {
      await _firebaseService.deleteQuiz(quizId); // Delete the quiz

      setState(() {
        _quizzes.removeWhere((quiz) => quiz['id'] == quizId); // Remove deleted quiz from the list
      });

      // Show success message upon deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    } catch (e) {
      // Show error message if deletion fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting quiz: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient decoration
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
              _buildAppBar(), // Custom app bar
              Expanded(
                child: Container(
                  // White background for quiz list section
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                      : _buildQuizList(), // Build quiz list when not loading
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(), // Floating action button to create a new quiz
    );
  }

  // Method to build the custom app bar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(), // Navigate back when the back button is pressed
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

  // Method to build the quiz list
  Widget _buildQuizList() {
    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No quizzes found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: _quizzes.length, // Number of quizzes
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildQuizCard(_quizzes[index]), // Build individual quiz card
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to build an individual quiz card
  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _navigateToQuizDetails(quiz), // Navigate to quiz details on tap
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quiz['name'], // Quiz name
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(quiz['id']), // Show delete confirmation dialog
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_events_rounded, color: Colors.green),
                    onPressed: () => _navigateToQuizOverview(quiz['id']), // Navigate to quiz overview
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoChip(Icons.subject, quiz['subject'] ?? 'Not specified'), // Quiz subject info chip
              const SizedBox(height: 4),
              _buildInfoChip(Icons.question_answer, '${quiz['questionCount'] - 1} questions'), // Number of questions info chip
              const SizedBox(height: 4),
              _buildInfoChip(
                Icons.calendar_today,
                'Created on ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(quiz['createdAt']))}', // Quiz creation date info chip
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build an info chip widget
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[800]),
          const SizedBox(width: 4),
          Text(
            label, // Chip label text
            style: TextStyle(fontSize: 12, color: Colors.blue[800]),
          ),
        ],
      ),
    );
  }

  // Method to build the floating action button for creating a new quiz
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateQuiz(), // Navigate to create quiz page
      icon: const Icon(Icons.add),
      label: const Text('Create Quiz'),
      backgroundColor: Colors.blue[800],
    );
  }

  // Method to navigate to the quiz details page
  void _navigateToQuizDetails(Map<String, dynamic> quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetailsPage(
          quizId: quiz['id'],
         

 initialQuizName: quiz['name'], // Pass quiz name and ID to the details page
        ),
      ),
    ).then((_) => _loadQuizzes()); // Reload quizzes after returning from the details page
  }

  // Method to navigate to the create quiz page
  void _navigateToCreateQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateQuizPage()),
    ).then((_) => _loadQuizzes()); // Reload quizzes after returning from the create quiz page
  }

  // Method to navigate to the quiz overview page
  void _navigateToQuizOverview(String quizId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LecturerQuizOverview(quizId: quizId)),
    ).then((_) => _loadQuizzes()); // Reload quizzes after returning from the quiz overview page
  }

  // Method to show a confirmation dialog before deleting a quiz
  void _showDeleteConfirmation(String quizId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quiz'),
          content: const Text('Are you sure you want to delete this quiz?'), // Confirmation message
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(), // Close dialog on cancel
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog and delete quiz
                _deleteQuiz(quizId);
              },
            ),
          ],
        );
      },
    );
  }
}