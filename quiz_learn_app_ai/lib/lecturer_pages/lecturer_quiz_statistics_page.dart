import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class LecturerQuizStatisticsPage extends StatefulWidget {
  const LecturerQuizStatisticsPage({super.key});

  @override
  LecturerQuizStatisticsPageState createState() => LecturerQuizStatisticsPageState();
}

class LecturerQuizStatisticsPageState extends State<LecturerQuizStatisticsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> _quizStatisticsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _initStatistics();
  }

  Future<void> _initStatistics() async {
    final lecturerId = await _firebaseService.getCurrentLecturerId();
    if (lecturerId != null) {
      setState(() {
        _quizStatisticsFuture = _firebaseService.loadLecturerQuizStatistics(lecturerId);
      });
    } else {
      setState(() {
        _quizStatisticsFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _quizStatisticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 16)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No quiz statistics available.', style: TextStyle(color: Colors.white, fontSize: 16)));
            } else {
              final quizzes = snapshot.data!;
              return ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                quiz['quizName'],
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const Icon(
                                Icons.assessment,
                                color: Colors.indigo,
                                size: 28.0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'Attempts: ${quiz['totalAttempts']}',
                            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                          Text(
                            'Avg. Score: ${quiz['averageScore'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: quiz['highestScore'] + 20.0, // Adjusted space above highest score
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        rod.toY.toString(),
                                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ),
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: quiz['highestScore'].toDouble(),
                                        color: Colors.green,
                                        width: 18, // Slightly narrower bars
                                        borderRadius: BorderRadius.circular(8.0),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: quiz['highestScore'] + 20.0,
                                          color: Colors.green.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                    showingTooltipIndicators: [0],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: quiz['lowestScore'].toDouble(),
                                        color: Colors.red,
                                        width: 18, // Slightly narrower bars
                                        borderRadius: BorderRadius.circular(8.0),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: quiz['highestScore'] + 20.0,
                                          color: Colors.red.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                    showingTooltipIndicators: [0],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return const Text('High', style: TextStyle(color: Colors.white, fontSize: 14));
                                          case 1:
                                            return const Text('Low', style: TextStyle(color: Colors.white, fontSize: 14));
                                          default:
                                            return const Text('', style: TextStyle(color: Colors.white, fontSize: 14));
                                        }
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 14));
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
