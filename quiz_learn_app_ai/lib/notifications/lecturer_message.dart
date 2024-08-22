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
    return LecturerMessage(
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      lectureEmail: map['lectureEmail'] as String,
      lecturerId: map['lecturerId'] as String,
      quizName: map['quizName'] as String,
      type: map['type'] as String,
      notificationId: map['notificationId'] as String,
    );
  }
}