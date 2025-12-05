import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/document.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../document/document_form_screen.dart';
import 'components/document_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: StreamBuilder<List<Document>>(
        stream: context.read<DocumentViewModel>().documentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Sin conexión', style: TextStyle(fontSize: 18)),
                  const Text('Los cambios se guardarán al recuperar internet'),
                  ElevatedButton(
                    onPressed: () => context.read<DocumentViewModel>().documentsStream(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text('Aún no tienes documentos', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentFormScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar el primero'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) => DocumentCard(document: docs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}