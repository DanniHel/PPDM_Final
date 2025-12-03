class Reminder {
  final String id;
  final String documentId;
  final DateTime alertDate;
  bool isSent;

  Reminder({
    required this.id,
    required this.documentId,
    required this.alertDate,
    this.isSent = false,
  });
}