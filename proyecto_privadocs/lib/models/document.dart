// lib/models/document.dart
import 'dart:io';
import 'package:hive/hive.dart';

part 'document.g.dart';

enum DocumentType { licencia, seguro, certificado, contrato, otro }

@HiveType(typeId: 0)
class Document extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) String name;
  @HiveField(3) int typeIndex;
  @HiveField(4) DateTime issueDate;
  @HiveField(5) DateTime? expiryDate;
  @HiveField(6) String fileLocalPath;
  @HiveField(7) String? fileName;
  @HiveField(8) String? fileRemoteUrl;
  @HiveField(9) bool isSynced;
  @HiveField(10) DateTime createdAt;
  @HiveField(11) DateTime updatedAt;

  Document({
    required this.id,
    required this.userId,
    required this.name,
    required this.typeIndex,
    required this.issueDate,
    this.expiryDate,
    required this.fileLocalPath,
    this.fileName,
    this.fileRemoteUrl,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentType get type => DocumentType.values[typeIndex];
  set type(DocumentType value) => typeIndex = value.index;

  bool get hasFile => fileLocalPath.isNotEmpty && File(fileLocalPath).existsSync();
  String get fileExtension => fileName?.split('.').last.toLowerCase() ?? '';

  Document copyWith({
    String? id,
    String? userId,
    String? name,
    int? typeIndex,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? fileLocalPath,
    String? fileName,
    String? fileRemoteUrl,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      typeIndex: typeIndex ?? this.typeIndex,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileName: fileName ?? this.fileName,
      fileRemoteUrl: fileRemoteUrl ?? this.fileRemoteUrl,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString(),
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'fileName': fileName,
      'fileLocalPath': fileLocalPath,
      'fileRemoteUrl': fileRemoteUrl,
      'isSynced': isSynced,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}