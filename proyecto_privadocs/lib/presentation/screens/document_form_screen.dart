// lib/presentation/screens/document_form_screen.dart
import 'package:flutter/material.dart';
import '../../core/routes.dart';

class DocumentFormScreen extends StatelessWidget {
  final dynamic document; // puede ser null (nuevo) o el documento a editar

  const DocumentFormScreen({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    final bool isEdit = document != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Documento' : 'Nuevo Documento'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: 'Nombre del documento')),
              TextField(decoration: InputDecoration(labelText: 'Tipo (Licencia, Seguro, etc.)')),
              TextField(decoration: InputDecoration(labelText: 'Fecha de emisión')),
              TextField(decoration: InputDecoration(labelText: 'Fecha de vencimiento')),
              SizedBox(height: 20),
              // Aquí irían los botones para adjuntar foto/PDF
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}