// lib/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../document/document_form_screen.dart';
import 'components/document_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // CARGA INMEDIATA al entrar en HomeScreen
    final userId = context.read<AuthViewModel>().currentUser!.uid;
    context.read<DocumentViewModel>().loadDocuments(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthViewModel>().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Document>>(
        stream: context.read<DocumentViewModel>().stream(userId),
        builder: (context, snapshot) {
          final docs = context.watch<DocumentViewModel>().documents;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text('No tienes documentos aún'),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentFormScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar primero'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) => DocumentCard(document: docs[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DocumentFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}