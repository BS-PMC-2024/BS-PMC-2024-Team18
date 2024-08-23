import 'package:intl/intl.dart';

class AdminMessage {
  final String subject;
  final String message;
  final DateTime date;
  final String adminEmail;
  final String notificationId;

  AdminMessage({
    required this.subject,
    required this.message,
    required this.date,
    required this.adminEmail,
    required this.notificationId,
  });

  factory AdminMessage.fromMap(Map<dynamic, dynamic> map) {
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

    return AdminMessage(
      subject: (map['subject'] as String?)?.isNotEmpty == true
          ? map['subject'] as String
          : 'Default Subject',
      message: (map['message'] as String?)?.isNotEmpty == true
          ? map['message'] as String
          : 'Default Message',
      date: dateWithoutMilliseconds,
      adminEmail: (map['AdminEmail'] as String?)?.isNotEmpty == true
          ? map['AdminEmail'] as String
          : 'default@example.com',
      notificationId: (map['notificationId'] as String?)?.isNotEmpty == true
          ? map['notificationId'] as String
          : 'default_id',
    );
  }
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
