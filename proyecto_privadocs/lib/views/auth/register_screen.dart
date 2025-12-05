import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(Icons.person_add, size: 90, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text('Únete a Privadocs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 30),

              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña (6+ caracteres)'), validator: (v) => v!.length < 6 ? 'Mínimo 6' : null),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: auth.isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await auth.signUp(_nameCtrl.text, _emailCtrl.text, _passCtrl.text);
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}