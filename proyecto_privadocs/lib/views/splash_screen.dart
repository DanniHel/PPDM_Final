import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    // Si ya sabemos si hay usuario → vamos directo
    if (authVM.firebaseUser != null) {
      return const HomeScreen();
    }
    if (authVM.firebaseUser == null && !authVM.isLoading) {
      return const LoginScreen();
    }

    // Mientras Firebase decide...
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder_special, size: 120, color: Colors.white),
            SizedBox(height: 30),
            Text(
              'Privadocs',
              style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}