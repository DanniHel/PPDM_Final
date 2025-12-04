import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../viewmodels/document_viewmodel.dart';
import 'document_form_screen.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DocumentFormScreen(document: document)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await context.read<DocumentViewModel>().deleteDocument(document.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${document.type.toString().split('.').last}', style: const TextStyle(fontSize: 18)),
            Text('Emitido: ${_formatDate(document.issueDate)}'),
            if (document.expiryDate != null) Text('Vence: ${_formatDate(document.expiryDate!)}'),
            const SizedBox(height: 20),
            if (document.filePath != null)
              if (document.fileName!.endsWith('.pdf'))
                const Text('PDF adjunto: Abre en visor externo')
              else
                Image.file(File(document.filePath!), height: 200, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}