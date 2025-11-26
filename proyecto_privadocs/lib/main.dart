// lib/main.dart
import 'package:flutter/material.dart';
import 'core/routes.dart';

void main() {
  runApp(const PrivadocsApp());
}

class PrivadocsApp extends StatelessWidget {
  const PrivadocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Privadocs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}