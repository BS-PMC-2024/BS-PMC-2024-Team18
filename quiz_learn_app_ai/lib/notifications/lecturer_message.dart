import 'package:intl/intl.dart';

class LecturerMessage {
  final DateTime date;
  final String description;
  final String lectureEmail;
  final String lecturerId;
  final String quizName;
  final String type;
  final String notificationId;

  LecturerMessage({
    required this.date,
    required this.description,
    required this.lectureEmail,
    required this.lecturerId,
    required this.quizName,
    required this.type,
    required this.notificationId,
  });

  factory LecturerMessage.fromMap(Map<dynamic, dynamic> map) {
    DateTime originalDate = map['date'] != null
        ? DateTime.parse(map['date'] as String)
        : DateTime.now();

    // Remove milliseconds by creating a new DateTime instance
    DateTime dateWithoutMilliseconds = DateTime(
      originalDate.year,
      originalDate.month,
      originalDate.day,
      originalDate.hour,
      originalDate.minute,
      
    );

    return LecturerMessage(
      date: dateWithoutMilliseconds,
      description: (map['description'] as String?)?.isNotEmpty == true
          ? map['description'] as String
          : 'Default Description',
      lectureEmail: (map['lectureEmail'] as String?)?.isNotEmpty == true
          ? map['lectureEmail'] as String
          : 'default@example.com',
      lecturerId: (map['lecturerId'] as String?)?.isNotEmpty == true
          ? map['lecturerId'] as String
          : 'default_lecturer_id',
      quizName: (map['quizName'] as String?)?.isNotEmpty == true
          ? map['quizName'] as String
          : 'Default Quiz Name',
      type: (map['type'] as String?)?.isNotEmpty == true
          ? map['type'] as String
          : 'Default Type',
      notificationId: (map['notificationId'] as String?)?.isNotEmpty == true
          ? map['notificationId'] as String
          : 'default_notification_id',
    );
  }
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
