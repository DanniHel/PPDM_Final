// lib/presentation/screens/document_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/routes.dart';

class DocumentDetailScreen extends StatelessWidget {
  final dynamic document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Documento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editDocument,
                arguments: {'document': document},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // confirmar y eliminar
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 120, color: Colors.indigo),
            SizedBox(height: 20),
            Text('Licencia de Conducir', style: TextStyle(fontSize: 24)),
            Text('Vence: 15/06/2026'),
          ],
        ),
      ),
    );
  }
}