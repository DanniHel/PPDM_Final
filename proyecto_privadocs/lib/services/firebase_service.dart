// lib/services/firebase_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;
  FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;


  // AUTH
  Future<User> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(name);
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred.user!;
  }

  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<void> signOut() => _auth.signOut();

  // RUTA LOCAL para guardar archivos
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // COPIAR archivo a carpeta local y devolver ruta
  Future<String> _copyFileToLocal(File sourceFile) async {
    final localPath = await _localPath;
    final fileName = '${const Uuid().v4()}_${path.basename(sourceFile.path)}';
    final newFile = await sourceFile.copy('$localPath/$fileName');
    return newFile.path;
  }

  // DOCUMENTOS
  Stream<List<Document>> getDocumentsStream(String userId) {
    return _firestore
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .orderBy('expiryDate', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => snapshot.docs
        .map((doc) => Document.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addDocument(Document doc, File? file) async {
    String? localPath;
    if (file != null) {
      localPath = await _copyFileToLocal(file);
    }

    await _firestore.collection('documents').doc(doc.id).set({
      ...doc.toMap(),
      'filePath': localPath,        // ahora es ruta local
      'fileName': file != null ? path.basename(file.path) : null,
    });
  }

  Future<void> updateDocument(Document doc, File? newFile) async {
    String? localPath = doc.filePath;
    String? fileName = doc.fileName;

    if (newFile != null) {
      localPath = await _copyFileToLocal(newFile);
      fileName = path.basename(newFile.path);
    }

    await _firestore.collection('documents').doc(doc.id).set({
      ...doc.toMap(),
      'filePath': localPath,
      'fileName': fileName,
    }, SetOptions(merge: true));
  }

  Future<void> deleteDocument(String docId, String? fileName) async {
    // Opcional: borrar archivo local
    final doc = await _firestore.collection('documents').doc(docId).get();
    final filePath = doc.data()?['filePath'] as String?;
    if (filePath != null && await File(filePath).exists()) {
      await File(filePath).delete();
    }
    await _firestore.collection('documents').doc(docId).delete();
  }
}