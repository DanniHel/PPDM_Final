// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ← IMPORTANTE
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/document.dart'; // ← NUEVO
import 'services/local_document_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/document_viewmodel.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← REGISTRAR HIVE + ADAPTER (ESTO FALTABA)
  await Hive.initFlutter();
  Hive.registerAdapter(DocumentAdapter()); // ← LA LÍNEA MÁGICA
  await Hive.openBox<Document>('documents'); // opcional, pero recomendado

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await LocalDocumentService.init();
  await SyncService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => SyncService()),
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