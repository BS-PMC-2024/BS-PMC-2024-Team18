import 'package:intl/intl.dart';

class StudentMessage {
  final String title;
  final String body;
  final String data;
  final DateTime timestamp;
  final String senderId;
  final String senderEmail;
  final String notificationId;

  StudentMessage({
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    required this.senderId,
    required this.senderEmail,
    required this.notificationId,
  });

  factory StudentMessage.fromMap(Map<dynamic, dynamic> map) {
    DateTime originalTimestamp = map['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
        : DateTime.now();

    // Remove milliseconds by creating a new DateTime instance
    DateTime timestampWithoutMilliseconds = DateTime(
      originalTimestamp.year,
      originalTimestamp.month,
      originalTimestamp.day,
      originalTimestamp.hour,
      originalTimestamp.minute,
      
    );

    return StudentMessage(
      title: (map['title'] as String?)?.isNotEmpty == true
          ? map['title'] as String
          : 'Default Title',
      body: (map['body'] as String?)?.isNotEmpty == true
          ? map['body'] as String
          : 'Default Body',
      data: (map['data'] as String?)?.isNotEmpty == true
          ? map['data'] as String
          : 'Default Data',
      timestamp: timestampWithoutMilliseconds,
      senderId: (map['senderId'] as String?)?.isNotEmpty == true
          ? map['senderId'] as String
          : 'default_sender_id',
      senderEmail: (map['senderEmail'] as String?)?.isNotEmpty == true
          ? map['senderEmail'] as String
          : 'default@example.com',
      notificationId: (map['notificationId'] as String?)?.isNotEmpty == true
          ? map['notificationId'] as String
          : 'default_notification_id',
    );
  }
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }
}