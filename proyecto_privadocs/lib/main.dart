import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/document_viewmodel.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        // Aquí irán AuthViewModel, etc.
      ],
      child: MaterialApp(
        title: 'Privadocs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
