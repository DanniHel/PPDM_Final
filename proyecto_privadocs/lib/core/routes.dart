// lib/core/routes.dart
import 'package:flutter/material.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/document_form_screen.dart';
import '../presentation/screens/document_detail_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addDocument = '/add-document';
  static const String editDocument = '/edit-document';
  static const String documentDetail = '/document-detail';

  static Map<String, Widget Function(BuildContext)> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    addDocument: (context) => const DocumentFormScreen(), // nuevo

    // Rutas que reciben argumentos
    editDocument: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return DocumentFormScreen(document: args?['document']);
    },

    documentDetail: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return DocumentDetailScreen(document: args?['document']);
    },
  };
}