// lib/models/document.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentType { licencia, seguro, certificado, contrato, otro }

class Document {
  final String id;
  final String userId;
  final String name;
  final DocumentType type;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? filePath;   // URL de Firebase Storage
  final String? fileName;

  Document({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.issueDate,
    this.expiryDate,
    this.filePath,
    this.fileName,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString(),
      'issueDate': Timestamp.fromDate(issueDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'filePath': filePath,
      'fileName': fileName,
    };
  }

  // Leer desde Firestore
  factory Document.fromMap(Map<String, dynamic> map, String docId) {
    return Document(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: _parseType(map['type']),
      issueDate: _toDateTime(map['issueDate']),
      expiryDate: map['expiryDate'] != null ? _toDateTime(map['expiryDate']) : null,
      filePath: map['filePath'],
      fileName: map['fileName'],
    );
  }

  // Método copyWith CORREGIDO (sin basura)
  Document copyWith({
    String? id,
    String? userId,
    String? name,
    DocumentType? type,
    DateTime? issueDate,
    DateTime? expiryDate,  // ← CORREGIDO: sin comentarios raros
    String? filePath,
    String? fileName,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
    );
  }

  // Helpers privados
  static DocumentType _parseType(String? typeStr) {
    if (typeStr == null) return DocumentType.otro;
    return DocumentType.values.firstWhere(
          (e) => e.toString() == typeStr,
      orElse: () => DocumentType.otro,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}

// Extensión para capitalizar texto (usado en las tarjetas)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}