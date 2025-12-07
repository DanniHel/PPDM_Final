import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _service.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _service.signIn(email.trim(), password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _service.signUp(name.trim(), email.trim(), password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false); // resetea
    }
  }

  Future<void> signOut() async {
    _setLoading(false); // Resetea al cerrar sesión
    await _service.signOut();
    notifyListeners();
  }
}