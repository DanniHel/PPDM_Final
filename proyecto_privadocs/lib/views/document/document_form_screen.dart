// lib/views/document/document_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/document.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../services/firebase_service.dart';

class DocumentFormScreen extends StatefulWidget {
  final Document? document;
  const DocumentFormScreen({super.key, this.document});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DocumentType _type;
  late DateTime _issueDate;
  DateTime? _expiryDate;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _name = widget.document!.name;
      _type = widget.document!.type;
      _issueDate = widget.document!.issueDate;
      _expiryDate = widget.document!.expiryDate;
    } else {
      _name = '';
      _type = DocumentType.otro;
      _issueDate = DateTime.now();
      _expiryDate = null;
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseService().currentUser?.uid ?? 'temp_user';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document == null ? 'Nuevo Documento' : 'Editar Documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre del documento',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Requerido' : null,
                onChanged: (v) => _name = v.trim(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<DocumentType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: DocumentType.values
                    .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.toString().split('.').last.capitalize()),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text('Fecha de emisión: ${_issueDate.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _issueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _issueDate = d);
                },
              ),

              ListTile(
                title: Text(_expiryDate == null
                    ? 'Sin fecha de vencimiento'
                    : 'Vence: ${_expiryDate!.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _expiryDate = d);
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Adjuntar foto o PDF'),
              ),

              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Archivo seleccionado: ${_selectedFile!.path.split('/').last}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final viewModel = context.read<DocumentViewModel>();

                  final newDoc = Document(
                    id: widget.document?.id ?? const Uuid().v4(),
                    userId: userId,
                    name: _name,
                    typeIndex: _type.index,
                    issueDate: _issueDate,
                    expiryDate: _expiryDate,
                    fileLocalPath: '', // se llena en el ViewModel
                    fileName: null,
                    fileRemoteUrl: null,
                    isSynced: false,
                    createdAt: widget.document?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  try {
                    if (widget.document == null) {
                      await viewModel.add(newDoc, _selectedFile);
                    } else {
                      await viewModel.updateDoc(newDoc, _selectedFile);
                    }

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(
                  widget.document == null ? 'GUARDAR DOCUMENTO' : 'ACTUALIZAR',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}