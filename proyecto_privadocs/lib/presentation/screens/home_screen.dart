// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // simulación
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.description, color: Colors.indigo),
            title: Text('Licencia de Conducir $index'),
            subtitle: const Text('Vence el 15/06/2026'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.documentDetail,
                arguments: {'document': 'doc $index'},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addDocument);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}