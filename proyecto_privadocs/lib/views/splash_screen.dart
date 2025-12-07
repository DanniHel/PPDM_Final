import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/document_viewmodel.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    if (user != null) {
      // Carga inmediata de documentos al iniciar sesión
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DocumentViewModel>().loadDocuments(user.uid);
      });
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}