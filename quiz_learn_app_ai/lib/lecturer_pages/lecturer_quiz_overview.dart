import 'package:flutter/material.dart';

class LecturerQuizOverview extends StatefulWidget {
  final String quizId;
  const LecturerQuizOverview({super.key, required this.quizId});

  @override
  _LecturerQuizOverviewState createState() => _LecturerQuizOverviewState();
}

class _LecturerQuizOverviewState extends State<LecturerQuizOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Overview ${widget.quizId}'),
      ),
      body: Container(
        // Add your UI components here
      ),
    );
  }
}