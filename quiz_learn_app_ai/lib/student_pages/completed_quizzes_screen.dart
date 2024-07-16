import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_learn_app_ai/quiz_pages/question_screen.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class CompletedQuizzesScreen extends StatefulWidget {
  const CompletedQuizzesScreen({super.key});

  @override
  CompletedQuizzesScreenState createState() => CompletedQuizzesScreenState();
}

class CompletedQuizzesScreenState extends State<CompletedQuizzesScreen> {
  List<Map<String, dynamic>> _completedQuizzes = [];
  List<Map<String, dynamic>> _filteredQuizzes = [];
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadCompletedQuizzes();
  }

 Future<void> _loadCompletedQuizzes() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Fetch all quizzes once
    final allQuizzes = await _firebaseService.loadAllQuizzes();

    _completedQuizzes = await _firebaseService.loadCompletedQuizzes();

    // Group quizzes by quizId and keep the most recent one
    final Map<String, Map<String, dynamic>> latestQuizzes = {};
    for (var quiz in _completedQuizzes) {
      final quizId = quiz['quizId'];
      if (!latestQuizzes.containsKey(quizId) ||
          DateTime.parse(quiz['date']).isAfter(
              DateTime.parse(latestQuizzes[quizId]!['date']))) {
        // Add questionCount from allQuizzes
        final quizInfo = allQuizzes.firstWhere(
          (q) => q['id'] == quizId,
          orElse: () => {'questionCount': 0},
        );

        latestQuizzes[quizId] = {
          ...quiz,
          'questionCount': quizInfo['questionCount'],
        };
      }
    }

    _filteredQuizzes = latestQuizzes.values.toList();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _filterQuizzes(String searchTerm) {
    setState(() {
      _filteredQuizzes = _completedQuizzes
          .where((quiz) => quiz['quizName'].toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Completed Quizzes',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: QuizSearchBar(onSearch: _filterQuizzes),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuizzes.isEmpty
                    ? Center(
                        child: Text(
                          'No completed quizzes found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredQuizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = _filteredQuizzes[index];
                          return _buildQuizCard(quiz);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToQuizScreen(quiz),
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
                      quiz['quizName'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  _buildScoreChip(quiz['points']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(DateTime.parse(quiz['date'])),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressIndicator(quiz),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToQuizScreen(quiz),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Retry Quiz'),
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

  Widget _buildProgressIndicator(Map<String, dynamic> quiz) {
    final totalQuestions = quiz['questionCount'] -1 ?? 0;
    final correctAnswers = quiz['rightAnswers']?.length ?? 0;
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

  void _navigateToQuizScreen(Map<String, dynamic> quiz) {
    final questionCount = quiz['questionCount'];
    if (questionCount != null && questionCount > 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            quizId: quiz['quizId'],
            quizName: quiz['quizName'],
          ),
        ),
      ).then((_) => _loadCompletedQuizzes());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This quiz has no questions.')),
      );
    }
  }
}

class QuizSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const QuizSearchBar({super.key, required this.onSearch});

  @override
  QuizSearchBarState createState() => QuizSearchBarState();
}

class QuizSearchBarState extends State<QuizSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search completed quizzes...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (value) => widget.onSearch(value),
      ),
    );
  }
}