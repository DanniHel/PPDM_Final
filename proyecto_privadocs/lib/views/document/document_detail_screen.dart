import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../viewmodels/document_viewmodel.dart';
import 'document_form_screen.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;
  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final daysLeft = document.expiryDate?.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DocumentFormScreen(document: document)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar'),
                  content: const Text('¿Seguro?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sí', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await context.read<DocumentViewModel>().delete(document.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // METADATOS
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(Icons.badge, 'Nombre', document.name),
                    _row(Icons.category, 'Tipo', document.type.toString().split('.').last.capitalize()),
                    _row(Icons.event, 'Emisión', _format(document.issueDate)),
                    if (document.expiryDate != null)
                      _row(
                        Icons.event_available,
                        'Vencimiento',
                        _format(document.expiryDate!),
                        color: daysLeft! < 0 ? Colors.red : daysLeft <= 7 ? Colors.orange : Colors.green,
                      ),
                    if (daysLeft != null && daysLeft < 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('VENCIDO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),

            // ARCHIVO
            if (document.hasFile)
              Container(
                height: 600,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: document.fileExtension == 'pdf'
                      ? SfPdfViewer.file(
                    File(document.fileLocalPath),
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    canShowPaginationDialog: true,
                  )
                      : Image.file(
                    File(document.fileLocalPath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 80, color: Colors.red),
                  ),
                ),
              )
            else
              const Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Sin archivo adjunto')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}