import 'package:flutter/material.dart';
import '../../../models/document.dart';
import '../../document/document_detail_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final daysLeft = document.expiryDate?.difference(DateTime.now()).inDays;

    return Card(
      child: ListTile(
        leading: Icon(document.fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.image),
        title: Text(document.name),
        subtitle: Text(document.type.name.capitalize()),
        trailing: daysLeft != null
            ? Text(daysLeft < 0 ? 'Vencido' : 'Quedan $daysLeft días', style: TextStyle(color: daysLeft < 0 ? Colors.red : daysLeft <= 7 ? Colors.orange : Colors.green))
            : null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentDetailScreen(document: document))),
      ),
    );
  }
}