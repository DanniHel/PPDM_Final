import 'dart:io';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class DocumentViewModel extends ChangeNotifier {
  final FirebaseService _db = FirebaseService();
  List<Document> _documents = [];
  List<Document> get documents => _documents;

  Stream<List<Document>> documentsStream() {
    final userId = _db.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    return _db.getDocumentsStream(userId);
  }

  Future<void> addDocument(Document doc, File? file) async {
    await _db.addDocument(doc, file);
    if (doc.expiryDate != null) {
      await NotificationService.scheduleReminder(doc);
    }
    notifyListeners();
  }

  Future<void> updateDocument(Document doc, File? file) async {
    await _db.updateDocument(doc, file);
    if (doc.expiryDate != null) {
      await NotificationService.scheduleReminder(doc);
    }
    notifyListeners();
  }

  Future<void> deleteDocument(String id, String? fileName) async {
    await _db.deleteDocument(id, fileName);
    notifyListeners();
  }


}