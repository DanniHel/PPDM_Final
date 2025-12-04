import 'package:flutter/material.dart';
import '../../../models/document.dart';
import '../../document/document_detail_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Icon(
            _getIconForType(document.type),
            color: Colors.indigo,
          ),
        ),
        title: Text(document.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${_typeToString(document.type)} • Vence: ${_formatDate(document.expiryDate)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentDetailScreen(document: document),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.licencia:
        return Icons.badge;
      case DocumentType.seguro:
        return Icons.security;
      case DocumentType.certificado:
        return Icons.school;
      case DocumentType.contrato:
        return Icons.description;
      default:
        return Icons.folder;
    }
  }

  String _typeToString(DocumentType type) {
    return type.toString().split('.').last.replaceFirst(type.toString().split('.').last[0], type.toString().split('.').last[0].toUpperCase());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin vencimiento';
    return '${date.day}/${date.month}/${date.year}';
  }
}