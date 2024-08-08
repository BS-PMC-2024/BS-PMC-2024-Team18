import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/quiz_pages/question_screen.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  QuizListScreenState createState() => QuizListScreenState();
}

class QuizListScreenState extends State<QuizListScreen> {

  List<Map<String, dynamic>> _allQuizzes = [];
  List<Map<String, dynamic>> _filteredQuizzes = [];
  bool _isLoading = false;
   String? userType;
     final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _loadAllQuizzes();
    _loadUserData();
  }

   Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> userData = await _firebaseService.loadUserData();
      if (mounted) {
        setState(() {
          userType = userData['userType'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


@override
Widget build(BuildContext context) { //  Widget builder for available quiz list
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        'All Quizzes',
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
                        'No quizzes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredQuizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _filteredQuizzes[index];
                        return _buildQuizCard(context, quiz);
                      },
                    ),
        ),
      ],
    ),
  );
}
Widget _buildQuizCard(BuildContext context, Map<String, dynamic> quiz) {
  List<dynamic> questions = quiz['questions'] ?? [];
  String description = quiz['description'] ?? 'No description available';

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () {
        if (userType == 'Lecturer') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lecturers cannot start quizzes.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _checkQuizAvailabilityAndStart(quiz);
        }
      },
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
                    quiz['name']?.toString() ?? 'Unnamed Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.report, size: 20, color: Colors.red),
                      onPressed: () => _showReportDialog(context, quiz['id']),
                      tooltip: 'Report',
                    ),
                    _buildQuestionCountChip(questions.length - 1),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quiz['subject']?.toString() ?? 'No Subject',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Lecturer: ${quiz['lecturer']?.toString() ?? 'Unknown'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(quiz['createdAt']?.toString() ?? '0'),
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (userType == 'Lecturer') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lecturers cannot start quizzes.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      _checkQuizAvailabilityAndStart(quiz);
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showReportDialog(BuildContext context, String quizId) {
    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Quiz'),
          content: TextField(
            controller: reportController,
            decoration: const InputDecoration(hintText: 'Enter report details'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _reportQuiz(context, quizId, reportController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

void _reportQuiz(BuildContext context, String quizId, String reportDetails) async {
  if (reportDetails.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report details cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  try {
    final currentUser = await _firebaseService.getCurrentLecturerId();
    final reportData = {
      'reportDetails': reportDetails,
      'reportedBy': currentUser ?? 'Anonymous',
      'reportDate': DateTime.now().millisecondsSinceEpoch,
    };

    await _firebaseService.reportQuiz(quizId, reportData);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz reported successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reporting quiz: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


void _checkQuizAvailabilityAndStart(Map<String, dynamic> quiz) {
  if (quiz['startTime'] != null && quiz['endTime'] != null) {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime.parse(quiz['startTime']);
    DateTime endTime = DateTime.parse(quiz['endTime']);

    if (now.isBefore(startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz will start on ${DateFormat('MMM d, yyyy HH:mm').format(startTime)}'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (now.isAfter(endTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz has ended.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _navigateToQuizScreen(quiz);
    }
  } else {
    // If startTime or endTime is not set, allow the quiz to start
    _navigateToQuizScreen(quiz);
  }
}



Widget _buildQuestionCountChip(int count) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$count Questions',
      style: TextStyle(
        color: Colors.blue[800],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

void _navigateToQuizScreen(Map<String, dynamic> quiz) { // Quiz navigation implementation
  if (quiz['questionCount'] > 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          quizId: quiz['id'],
          quizName: quiz['name'],
        ),
      ),
    ).then((_) => _loadAllQuizzes());
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This quiz has no questions.')),
    );
  }
}





Future<void> _loadAllQuizzes() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Assuming you have an instance of FirebaseService called _firebaseService
    _allQuizzes = await _firebaseService.loadAllQuizzes();
    _filteredQuizzes = List.from(_allQuizzes);
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

void _filterQuizzes(String searchTerm, String lecturer, String subject,
    DateTime? startDate, DateTime? endDate) {
  setState(() {
    _filteredQuizzes = _firebaseService.filterQuizzes(
      _allQuizzes,
      searchTerm,
      lecturer,
      subject,
      startDate,
      endDate
    );
  });
}
}

class QuizSearchBar extends StatefulWidget {
  final Function(String, String, String, DateTime?, DateTime?) onSearch;

  const QuizSearchBar({super.key, required this.onSearch});

  @override
  QuizSearchBarState createState() => QuizSearchBarState();
}

class QuizSearchBarState extends State<QuizSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLecturer = 'All';
  String _selectedSubject = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late Future<List<String>> _lecturersFuture;

  @override
  void initState() {
    super.initState();
    _lecturersFuture = _loadLecturers();
  }

Future<List<String>> _loadLecturers() async {
  try {
    final snapshot = await _database.ref().child('lecturers').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<String> lecturers = ['All']; // Add 'All' as the first option

      Map<String, int> nameCount = {};

      data.forEach((lecturerId, lecturerData) {
        String name = lecturerData['name'] ?? 'Unknown Lecturer';
        // Count occurrences of each name
        if (nameCount.containsKey(name)) {
          nameCount[name] = nameCount[name]! + 1;
        } else {
          nameCount[name] = 1;
        }
        // Append index only if there are duplicates
        if (nameCount[name]! > 1) {
          lecturers.add('$name (${nameCount[name]})');
        } else {
          lecturers.add(name);
        }
      });

      return lecturers;
    } else {
      return ['All'];
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lecturers: ${e.toString()}')),
      );
    }
    return ['All'];
  }
}

 @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildLecturerDropdown(),
        const SizedBox(height: 16),
        _buildSubjectDropdown(),
        const SizedBox(height: 16),
        _buildDateRangeSelector(context),
      ],
    ),
  );
}

Widget _buildSearchField() {
  return TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search quizzes...',
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
    ),
    onChanged: (value) => _performSearch(),
  );
}

Widget _buildLecturerDropdown() {
  return FutureBuilder<List<String>>(
    future: _lecturersFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
      } else {
        return _buildDropdown(
          value: _selectedLecturer,
          items: snapshot.data!,
          hint: 'Select Lecturer',
          onChanged: (value) {
            setState(() {
              _selectedLecturer = value!;
              _performSearch();
            });
          },
        );
      }
    },
  );
}


Widget _buildSubjectDropdown() {
  return _buildDropdown(
    value: _selectedSubject,
    items: [
              'All',
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
            ],
    hint: 'Select Subject',
    onChanged: (value) {
      setState(() {
        _selectedSubject = value!;
        _performSearch();
      });
    },
  );
}

Widget _buildDropdown({
  required String? value,
  required List<String> items,
  required String hint,
  required Function(String?) onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(30),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget _buildDateRangeSelector(BuildContext context) {
  return InkWell(
    onTap: () => _selectDateRange(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _startDate == null
                ? 'Select Date Range'
                : '${DateFormat('MM/dd/yyyy').format(_startDate!)} - ${DateFormat('MM/dd/yyyy').format(_endDate!)}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.grey[600]),
              if (_startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _performSearch();
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _performSearch();
      });
    }
  }

  void _performSearch() {
    widget.onSearch(
      _searchController.text,
      _selectedLecturer,
      _selectedSubject,
      _startDate,
      _endDate,
    );
  }
}
