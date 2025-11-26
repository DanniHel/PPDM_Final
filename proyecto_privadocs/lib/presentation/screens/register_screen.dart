// lib/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../../core/routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Nombre')),
            TextField(decoration: InputDecoration(labelText: 'Correo')),
            TextField(decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
            SizedBox(height: 20),
            // Aquí iría el botón de registro real
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}