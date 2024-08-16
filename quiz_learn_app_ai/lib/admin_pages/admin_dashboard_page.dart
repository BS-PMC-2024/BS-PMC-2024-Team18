import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';
import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  AdminDashboardPageState createState() => AdminDashboardPageState();
}

class AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseService _firebaseService = FirebaseService();

  int _registeredUserCount = 0;
  int _activeUserCount = 0;
  int _quizCompletionCount = 0;
  int _totalQuizzesCreated = 0;
  int _totalFeedbackReceived = 0;
  List<String> _systemAlerts = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final registeredUserCount = await _firebaseService.getRegisteredUserCount();
      final activeUserCount = await _firebaseService.getActiveUserCount();
      final quizCompletionCount = await _firebaseService.getQuizCompletionCount();
      final totalQuizzesCreated = await _firebaseService.getTotalQuizzesCreated();
      final totalFeedbackReceived = await _firebaseService.getTotalFeedbackReceived();
      final systemAlerts = await _firebaseService.getSystemPerformanceAlerts();

      setState(() {
        _registeredUserCount = registeredUserCount;
        _activeUserCount = activeUserCount;
        _quizCompletionCount = quizCompletionCount;
        _totalQuizzesCreated = totalQuizzesCreated;
        _totalFeedbackReceived = totalFeedbackReceived;
        _systemAlerts = systemAlerts;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: 6 + _systemAlerts.length,
                itemBuilder: (context, index) {
                  if (index < 6) {
                    switch (index) {
                      case 0:
                        return _buildMetricCard('Registered Users', _registeredUserCount, Icons.person);
                      case 1:
                        return _buildMetricCard('Active Users', _activeUserCount, Icons.people);
                      case 2:
                        return _buildMetricCard('Quiz Completions', _quizCompletionCount, Icons.check_circle);
                      case 3:
                        return _buildMetricCard('Total Quizzes', _totalQuizzesCreated, Icons.library_books);
                      case 4:
                        return _buildMetricCard('Feedback Received', _totalFeedbackReceived, Icons.feedback);
                      case 5:
                        return _buildShareButton(); // Adding the share button
                    }
                  } else {
                    return _buildAlertCard(_systemAlerts[index - 6]);
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, dynamic value, IconData icon) {
    return OpenContainer(
      closedElevation: 10,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      closedColor: Colors.white.withOpacity(0.1),
      openBuilder: (context, _) => DetailPage(title: title, value: value),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.cyanAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Text(
                value.toString(),
                style: GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(String alert) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.redAccent.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(
              'Alert',
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            Text(
              alert,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.redAccent),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: _shareDetails,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          gradient: LinearGradient(
            colors: [Colors.cyan.withOpacity(0.3), Colors.cyan.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              'Share Dashboard',
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _shareDetails() {
    final details = '''
Admin Dashboard Details:
- Registered Users: $_registeredUserCount
- Active Users: $_activeUserCount
- Quiz Completions: $_quizCompletionCount
- Total Quizzes Created: $_totalQuizzesCreated
- Feedback Received: $_totalFeedbackReceived
- System Alerts: ${_systemAlerts.isNotEmpty ? _systemAlerts.join(", ") : "No alerts"}

Check out more on the Admin Dashboard!
    ''';

    Share.share(details);
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final dynamic value;

  const DetailPage({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, value.toDouble()),
                    FlSpot(1, value.toDouble() + 1),
                    FlSpot(2, value.toDouble() - 1),
                    FlSpot(3, value.toDouble() + 2),
                  ],
                  isCurved: true,
                  color: Colors.cyanAccent,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: true, color: Colors.cyanAccent.withOpacity(0.3)),
                ),
              ],
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
