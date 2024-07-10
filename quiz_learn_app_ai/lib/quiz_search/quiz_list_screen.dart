import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  QuizListScreenState createState() => QuizListScreenState();
}

class QuizListScreenState extends State<QuizListScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Map<String, dynamic>> _allQuizzes = [];
  List<Map<String, dynamic>> _filteredQuizzes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllQuizzes();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('All Quizzes')),
    body: Column(
      children: [
        QuizSearchBar(onSearch: _filterQuizzes),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredQuizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _filteredQuizzes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz['name'].toString(), style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('${quiz['subject'].toString()} - ${quiz['questionCount'].toString()} questions'),
                            const SizedBox(height: 4),
                            Text('Lecturer: ${quiz['lecturer'].toString()}'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('MM/dd/yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(quiz['createdAt'].toString()))
                                )),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to quiz details or start quiz
                                  },
                                  child: const Text('Enter Quiz'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}





  Future<void> _loadAllQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _database.ref().child('lecturers').get();


      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _allQuizzes = [];

        data.forEach((lecturerId, lecturerData) {
          if (lecturerData['quizzes'] != null) {
            final quizzes = lecturerData['quizzes'] as Map<dynamic, dynamic>;
            quizzes.forEach((quizId, quizData) {
              _allQuizzes.add({
                'id': quizId,
                'name': quizData['name'],
                'subject': quizData['subject'],
                'createdAt': quizData['createdAt'],
                'questionCount': (quizData['questions'] as List).length,
                'lecturer': lecturerData['name'] ?? 'Unknown Lecturer',
              });
            });
          }
        });

        _allQuizzes.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        _filteredQuizzes = List.from(_allQuizzes);
      }
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

void _filterQuizzes(String searchTerm, String lecturer, String subject, DateTime? startDate, DateTime? endDate) {
  setState(() {
    _filteredQuizzes = _allQuizzes.where((quiz) {
      bool matchesSearch = quiz['name'].toString().toLowerCase().contains(searchTerm.toLowerCase()) ||
          quiz['subject'].toString().toLowerCase().contains(searchTerm.toLowerCase()) ||
          quiz['lecturer'].toString().toLowerCase().contains(searchTerm.toLowerCase());
      bool matchesLecturer = lecturer == 'All' || quiz['lecturer'].toString() == lecturer;
      bool matchesSubject = subject == 'All' || quiz['subject'].toString() == subject;
      bool matchesDate = true;
      if (startDate != null && endDate != null) {
        // Parse the timestamp to DateTime
        DateTime quizDate = DateTime.fromMillisecondsSinceEpoch(int.parse(quiz['createdAt'].toString()));
        matchesDate = quizDate.isAfter(startDate) && quizDate.isBefore(endDate.add(const Duration(days: 1)));
      }
      return matchesSearch && matchesLecturer && matchesSubject && matchesDate;
    }).toList();
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
        List<String> lecturers = ['All'];  // Add 'All' as the first option

        data.forEach((lecturerId, lecturerData) {
          lecturers.add(lecturerData['name'] ?? 'Unknown Lecturer');
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
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onChanged: (value) => _performSearch(),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<String>>(
            future: _lecturersFuture,
            builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    } else if (snapshot.hasError) {
                return const Text('Error loading lecturers');
              } else {
                return DropdownButtonFormField<String>(
                  value: _selectedLecturer,
                  decoration: const InputDecoration(
                    labelText: 'Lecturer',
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLecturer = value!;
                      _performSearch();
                    });
                  },
                );
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
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
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value!;
                _performSearch();
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    _startDate == null
                        ? 'Select Date Range'
                        : '${DateFormat('MM/dd/yyyy').format(_startDate!)} - ${DateFormat('MM/dd/yyyy').format(_endDate!)}',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
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
