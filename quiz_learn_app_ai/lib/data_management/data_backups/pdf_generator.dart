import 'dart:io';
import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/framework.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_send_messages.dart';

class PdfGenerator {
  static Future<File> generateUserDataPdf(List<UserDataToken> users, BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['ID', 'Email', 'User Type', 'Device Token'],
              ...users.map((user) => [
                    user.id,
                    user.email,
                    user.userType,
                    user.deviceToken,
                  ]),
            ],
          ),
        ],
      ),
    );

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    // Define the path for the nested directories
    final path =
        Directory('${directory.path}/lib/data_management/data_backups');

    // Create the directory if it doesn't exist
    if (!await path.exists()) {
      await path.create(recursive: true);
    }

    // Define the file path and name
    final filePath =
        '${path.path}/user_data_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);

    // Write the PDF file
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generateQuizDataPdf(
      List<Map<String, dynamic>> quizzes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>[
                'ID',
                'Name',
                'Subject',
                'Created At',
                'Questions Count',
                'Lecturer',
                'Start Time',
                'End Time'
              ],
              ...quizzes.map((quiz) => [
                    quiz['id'].toString(),
                    quiz['name'] ?? 'N/A',
                    quiz['subject'] ?? 'N/A',
                    quiz['createdAt'].toString(),
                    quiz['questionCount'].toString(),
                    quiz['lecturer'],
                    quiz['startTime'].toString(),
                    quiz['endTime'].toString(),
                  ]),
            ],
          ),
        ],
      ),
    );

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    // Define the path for the file
    final path =
        Directory('${directory.path}/lib/data_management/data_backups');

    // Create the directory if it doesn't exist
    if (!await path.exists()) {
      await path.create(recursive: true);
    }

    // Define the file path and name
    final filePath =
        '${path.path}/quiz_data_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);

    // Write the PDF file
    await file.writeAsBytes(await pdf.save());

    if (kDebugMode) {
      print('PDF saved at: $filePath');
    }
    return file;
  }
}
