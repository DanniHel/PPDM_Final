import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';

class LocalDocumentService {
  static const String _boxName = 'documents';
  static late Box<Document> _box;
  static String docsDir = '';

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Document>(_boxName);

    final dir = await getApplicationDocumentsDirectory();
    docsDir = '${dir.path}/privadocs_files';
    final folder = Directory(docsDir);
    if (!await folder.exists()) await folder.create(recursive: true);
  }

  static Future<String> saveFile(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final newPath = '$docsDir/$fileName';
    await file.copy(newPath);
    return newPath;
  }

  static Future<void> add(Document doc) async => await _box.put(doc.id, doc);
  static Future<void> update(Document doc) async => await _box.put(doc.id, doc);

  static Future<void> delete(String id) async {
    final doc = _box.get(id);
    if (doc?.hasFile == true) {
      try { await File(doc!.fileLocalPath).delete(); } catch (_) {}
    }
    await _box.delete(id);
  }

  static List<Document> getAll(String userId) {
    return _box.values
        .where((d) => d.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Stream<List<Document>> watch(String userId) {
    return _box.watch().map((_) => getAll(userId));
  }
}