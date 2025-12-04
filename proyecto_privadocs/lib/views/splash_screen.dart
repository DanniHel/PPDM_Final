import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../viewmodels/auth_viewmodel.dart'; // lo crearemos en un segundo
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos una pequeña carga y decidimos a dónde ir
    Future.delayed(const Duration(seconds: 2), () {
      // Por ahora vamos directo al login (cuando tengamos AuthViewModel será más inteligente)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_special_outlined, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Privadocs',
              style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}