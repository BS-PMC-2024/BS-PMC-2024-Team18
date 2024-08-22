import 'package:intl/intl.dart';

class IssueReportNotifications {
  final String title;
  final String subject;
  final String data;
  final DateTime date;
  final String notificationId;
  final String sender;
  final String senderEmail;
  final List<String> informedAdmins;

  IssueReportNotifications({
    required this.title,
    required this.subject,
    required this.data,
    required this.date,
    required this.notificationId,
    required this.sender,
    required this.senderEmail,
    required this.informedAdmins,
  });

  factory IssueReportNotifications.fromMap(Map<dynamic, dynamic> map) {
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

    return IssueReportNotifications(
      title: (map['title'] as String?)?.isNotEmpty == true
          ? map['title'] as String
          : 'Default Title',
      subject: (map['subject'] as String?)?.isNotEmpty == true
          ? map['subject'] as String
          : 'Default Subject',
      data: (map['data'] as String?)?.isNotEmpty == true
          ? map['data'] as String
          : 'Default Data',
      date: dateWithoutMilliseconds,
      notificationId: (map['notificationId'] as String?)?.isNotEmpty == true
          ? map['notificationId'] as String
          : 'default_id',
      sender: (map['sender'] as String?)?.isNotEmpty == true
          ? map['sender'] as String
          : 'Default Sender',
      senderEmail: (map['senderEmail'] as String?)?.isNotEmpty == true
          ? map['senderEmail'] as String
          : 'default@example.com',
      informedAdmins: map['InformedAdmins'] != null && map['InformedAdmins'] is List
          ? List<String>.from(map['InformedAdmins'] as List)
          : <String>[], // Default to an empty list if null
    );
  }
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}