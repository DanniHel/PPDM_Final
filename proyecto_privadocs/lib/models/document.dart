import 'package:uuid/uuid.dart';

enum DocumentType { licencia, seguro, certificado, contrato, otro }

class Document {
  String id;
  String userId;
  String name;
  DocumentType type;
  DateTime issueDate;
  DateTime? expiryDate;        // puede no tener vencimiento
  String? filePath;            // ruta local o URL cuando esté en Firebase Storage
  String? fileName;

  Document({
    String? id,
    required this.userId,
    required this.name,
    required this.type,
    required this.issueDate,
    this.expiryDate,
    this.filePath,
    this.fileName,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.index,
      'issueDate': issueDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'filePath': filePath,
      'fileName': fileName,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      type: DocumentType.values[map['type']],
      issueDate: DateTime.fromMillisecondsSinceEpoch(map['issueDate']),
      expiryDate: map['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      filePath: map['filePath'],
      fileName: map['fileName'],
    );
  }
}