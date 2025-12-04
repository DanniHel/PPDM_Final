import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../services/local_database_service.dart';
import '../../services/notification_service.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../utils/constants.dart'; // lo crearemos abajo

class DocumentFormScreen extends StatefulWidget {
  final Document? document; // null si es nuevo

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
  String? _filePath;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _name = widget.document!.name;
      _type = widget.document!.type;
      _issueDate = widget.document!.issueDate;
      _expiryDate = widget.document!.expiryDate;
      _filePath = widget.document!.filePath;
      _fileName = widget.document!.fileName;
    } else {
      _name = '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _filePath = pickedFile.path;
        _fileName = pickedFile.name;
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final doc = Document(
        id: widget.document?.id,
        userId: LocalDatabaseService().currentUser!.id, // temporal
        name: _name,
        type: _type,
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        filePath: _filePath,
        fileName: _fileName,
      );

      final vm = context.read<DocumentViewModel>();
      if (widget.document == null) {
        await vm.addDocument(doc);
      } else {
        await vm.updateDocument(doc);
      }

      // Configurar notificación si hay vencimiento
      if (_expiryDate != null) {
        await NotificationService.scheduleReminder(doc);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.document == null ? 'Nuevo Documento' : 'Editar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DocumentType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: DocumentType.values.map((t) => DropdownMenuItem(value: t, child: Text(_typeToString(t)))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Fecha de Emisión: ${_formatDate(_issueDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _issueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _issueDate = date);
                },
              ),
              ListTile(
                title: Text('Fecha de Vencimiento: ${_expiryDate == null ? 'Ninguna' : _formatDate(_expiryDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() => _expiryDate = date);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Seleccionar Imagen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickPdf,
                      child: const Text('Seleccionar PDF'),
                    ),
                  ),
                ],
              ),
              if (_fileName != null) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Archivo: $_fileName', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Guardar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _typeToString(DocumentType t) => t.toString().split('.').last.capitalize();
}