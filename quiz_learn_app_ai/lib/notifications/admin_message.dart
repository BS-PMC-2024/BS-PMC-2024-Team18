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
    return AdminMessage(
      subject: map['subject'] as String,
      message: map['message'] as String,
      date: DateTime.parse(map['date'] as String), // Parse the date string
      adminEmail: map['AdminEmail'] as String,
      notificationId: map['notificationId'] as String,
    );
  }
}