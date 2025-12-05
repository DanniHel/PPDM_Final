import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../services/firebase_service.dart';
import '../../viewmodels/document_viewmodel.dart';

class DocumentFormScreen extends StatefulWidget {
  final Document? document;
  const DocumentFormScreen({super.key, this.document});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  DocumentType _type = DocumentType.otro;
  DateTime _issueDate = DateTime.now();
  DateTime? _expiryDate;
  File? _selectedFile;
  String? _existingFileUrl;
  String? _existingFileName;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _name = widget.document!.name;
      _type = widget.document!.type;
      _issueDate = widget.document!.issueDate;
      _expiryDate = widget.document!.expiryDate;
      _existingFileUrl = widget.document!.filePath;
      _existingFileName = widget.document!.fileName;
    } else {
      _name = '';
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.document == null ? 'Nuevo Documento' : 'Editar')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
            onChanged: (v) => _name = v,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DocumentType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: DocumentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.toString().split('.').last.capitalize()))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          ListTile(title: Text('Emisión: ${_format(_issueDate)}'), trailing: const Icon(Icons.calendar_today), onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _issueDate, firstDate: DateTime(2000), lastDate: DateTime.now());
            if (d != null) setState(() => _issueDate = d);
          }),
          ListTile(title: Text('Vencimiento: ${_expiryDate == null ? 'Sin fecha' : _format(_expiryDate!)}'), trailing: const Icon(Icons.calendar_today), onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _expiryDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
            if (d != null) setState(() => _expiryDate = d);
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.attach_file), label: const Text('Adjuntar archivo')),
          if (_selectedFile != null || _existingFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Archivo: ${_selectedFile?.path.split('/').last ?? _existingFileName}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final doc = Document(
                  id: widget.document?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: FirebaseService().currentUser?.uid ?? '',
                  name: _name.trim(),
                  type: _type,
                  issueDate: _issueDate,
                  expiryDate: _expiryDate,
                  filePath: _existingFileUrl,
                  fileName: _existingFileName,
                );
                final vm = context.read<DocumentViewModel>();
                widget.document == null ? await vm.addDocument(doc, _selectedFile) : await vm.updateDocument(doc, _selectedFile);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ]),
      ),
    );
  }

  String _format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}