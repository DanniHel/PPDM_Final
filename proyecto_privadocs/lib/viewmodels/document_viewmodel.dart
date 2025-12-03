import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/local_database_service.dart';

class DocumentViewModel extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    final userId = _db.currentUser?.id;
    if (userId != null) {
      _documents = _db.getDocuments(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDocument(Document doc) async {
    await _db.addDocument(doc);
    await loadDocuments();
  }

  Future<void> updateDocument(Document doc) async {
    await _db.updateDocument(doc);
    await loadDocuments();
  }

  Future<void> deleteDocument(String id) async {
    await _db.deleteDocument(id);
    await loadDocuments();
  }
}