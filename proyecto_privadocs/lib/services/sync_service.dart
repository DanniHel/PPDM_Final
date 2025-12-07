import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/document.dart';
import 'local_document_service.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  bool _isSyncing = false;
  int _pending = 0;
  StreamSubscription? _sub;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pending;

  static Future<void> init() async {
    final service = SyncService();
    await service._sync();
    service._sub = Connectivity().onConnectivityChanged.listen((r) {
      if (r != ConnectivityResult.none) service._sync();
    });
  }

  Future<void> _sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    final unsynced = LocalDocumentService.getAll('').where((d) => !d.isSynced).toList();
    _pending = unsynced.length;
    notifyListeners();

    for (var doc in unsynced) {
      try {
        if (doc.hasFile) {
          final ref = FirebaseStorage.instance
              .ref('documents/${doc.userId}/${doc.id}_${doc.fileName}');
          await ref.putFile(File(doc.fileLocalPath));
          final url = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('documents')
              .doc(doc.id)
              .set(doc.copyWith(fileRemoteUrl: url, isSynced: true).toMap());

          await LocalDocumentService.update(doc.copyWith(fileRemoteUrl: url, isSynced: true));
        }
      } catch (e) {
        debugPrint("Sync error: $e");
      }
    }

    _isSyncing = false;
    _pending = 0;
    notifyListeners();
  }

  Future<void> forceSync() => _sync();
}