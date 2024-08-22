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
    return StudentMessage(
      title: map['title'] as String,
      body: map['body'] as String,
      data: map['data'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      senderId: map['senderId'] as String,
      senderEmail: map['senderEmail'] as String,
      notificationId: map['notificationId'] as String,
    );
  }
}