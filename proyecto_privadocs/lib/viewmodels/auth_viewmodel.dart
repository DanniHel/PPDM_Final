import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  User? get firebaseUser => _service.currentUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _service.signIn(email.trim(), password);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _service.signUp(name.trim(), email.trim(), password);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}