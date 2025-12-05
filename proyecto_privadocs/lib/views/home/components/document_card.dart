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
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentDetailScreen(document: document))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getColor(daysLeft).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  document.fileName?.endsWith('.pdf') == true ? Icons.picture_as_pdf : Icons.image,
                  size: 32,
                  color: _getColor(daysLeft),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.type.toString().split('.').last.capitalize(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (document.expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        daysLeft! < 0
                            ? 'Vencido'
                            : daysLeft == 0
                            ? 'Vence hoy'
                            : 'Vence en $daysLeft días',
                        style: TextStyle(
                          color: daysLeft < 0 ? Colors.red : daysLeft <= 7 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(int? daysLeft) {
    if (daysLeft == null) return Colors.indigo;
    if (daysLeft < 0) return Colors.red;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }
}
