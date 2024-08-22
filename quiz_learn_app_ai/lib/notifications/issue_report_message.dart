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
    return IssueReportNotifications(
      title: map['title'] as String,
      subject: map['subject'] as String,
      data: map['data'] as String,
      date: DateTime.parse(map['date'] as String),
      notificationId: map['notificationId'] as String,
      sender: map['sender'] as String,
      senderEmail: map['senderEmail'] as String,
      informedAdmins: List<String>.from(map['InformedAdmins'] as List),
    );
  }
}
