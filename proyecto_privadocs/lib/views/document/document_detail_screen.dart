import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/document.dart';
import '../../viewmodels/document_viewmodel.dart';
import 'document_form_screen.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;
  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final isPdf = document.fileName?.toLowerCase().endsWith('.pdf') == true;
    final daysLeft = document.expiryDate != null ? document.expiryDate!.difference(DateTime.now()).inDays : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentFormScreen(document: document)))),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
              title: const Text('Eliminar'),
              content: const Text('¿Seguro? Esta acción no se puede deshacer.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red)))],
            ));
            if (confirm == true) {
              await context.read<DocumentViewModel>().deleteDocument(document.id, document.fileName);
              if (context.mounted) Navigator.pop(context);
            }
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(Icons.category, 'Tipo', document.type.toString().split('.').last.capitalize()),
                    const Divider(),
                    _row(Icons.event, 'Emisión', _format(document.issueDate)),
                    if (document.expiryDate != null) ...[
                      const Divider(),
                      _row(Icons.event_available, 'Vencimiento', _format(document.expiryDate!), color: daysLeft! < 0 ? Colors.red : daysLeft <= 7 ? Colors.orange : Colors.green),
                      if (daysLeft < 0) const Padding(padding: EdgeInsets.only(top: 10), child: Text('¡Vencido!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (document.filePath != null)
              Card(
                child: isPdf
                    ? ListTile(
                  leading: const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                  title: Text(document.fileName ?? 'Archivo PDF'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse(document.filePath!)),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: document.filePath != null && File(document.filePath!).existsSync()
                      ? Image.file(
                    File(document.filePath!),
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
                  )
                      : Container(
                    height: 400,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.description, size: 80, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.indigo),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color))]),
      ],
    );
  }

  String _format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

}