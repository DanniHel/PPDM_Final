import '../models/document.dart';
import '../models/app_user.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  AppUser? _currentUser;
  final List<Document> _documents = [];

  // Auth simulado
  AppUser? get currentUser => _currentUser;

  Future<AppUser> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(id: DateTime.now().toString(), name: name, email: email);
    return _currentUser!;
  }

  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(id: "temp_user_123", name: "Usuario Temporal", email: email);
    return _currentUser!;
  }

  // Documentos
  List<Document> getDocuments(String userId) {
    return _documents.where((d) => d.userId == userId).toList();
  }

  Future<void> addDocument(Document doc) async {
    _documents.add(doc);
  }

  Future<void> updateDocument(Document doc) async {
    final index = _documents.indexWhere((d) => d.id == doc.id);
    if (index != -1) _documents[index] = doc;
  }

  Future<void> deleteDocument(String id) async {
    _documents.removeWhere((d) => d.id == id);
  }
}