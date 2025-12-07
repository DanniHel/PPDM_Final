// lib/viewmodels/document_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/local_document_service.dart';
import '../services/notification_service.dart';

class DocumentViewModel extends ChangeNotifier {
  List<Document> _docs = [];
  List<Document> get documents => _docs;

  // Stream que se actualiza AUTOMÁTICAMENTE cuando hay cambios
  Stream<List<Document>> stream(String userId) {
    return LocalDocumentService.watch(userId).map((list) {
      _docs = list;
      notifyListeners();
      return list;
    });
  }

  // ← NUEVO: Método para forzar recarga inmediata después del login
  void loadDocuments(String userId) {
    _docs = LocalDocumentService.getAll(userId); // ← CARGA INMEDIATA
    notifyListeners();
  }

  Future<void> add(Document doc, File? file) async {
    String filePath = '';
    String? fileName;
    if (file != null) {
      filePath = await LocalDocumentService.saveFile(file);
      fileName = file.path.split('/').last;
    }

    final newDoc = Document(
      id: const Uuid().v4(),
      userId: doc.userId,
      name: doc.name,
      typeIndex: doc.typeIndex,
      issueDate: doc.issueDate,
      expiryDate: doc.expiryDate,
      fileLocalPath: filePath,
      fileName: fileName,
      fileRemoteUrl: null,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await LocalDocumentService.add(newDoc);

    if (newDoc.expiryDate != null) {
      await NotificationService.scheduleReminder(newDoc);
    }

    notifyListeners(); // ← Para que aparezca al instante
  }

  Future<void> updateDoc(Document oldDoc, File? newFile) async {
    String filePath = oldDoc.fileLocalPath;
    String? fileName = oldDoc.fileName;

    if (newFile != null) {
      filePath = await LocalDocumentService.saveFile(newFile);
      fileName = newFile.path.split('/').last;
    }

    final updatedDoc = oldDoc.copyWith(
      name: oldDoc.name,
      typeIndex: oldDoc.typeIndex,
      issueDate: oldDoc.issueDate,
      expiryDate: oldDoc.expiryDate,
      fileLocalPath: filePath,
      fileName: fileName,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await LocalDocumentService.update(updatedDoc);

    if (updatedDoc.expiryDate != null) {
      await NotificationService.scheduleReminder(updatedDoc);
    }

    notifyListeners();
  }

  Future<void> delete(String id) async {
    await LocalDocumentService.delete(id);
    notifyListeners();
  }
}