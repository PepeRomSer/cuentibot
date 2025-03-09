import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Cargar variables desde .env

  await Supabase.initialize(
    url: 'https://fyurdmhsabygsrbeerkp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5dXJkbWhzYWJ5Z3NyYmVlcmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA2OTQ2NzQsImV4cCI6MjA1NjI3MDY3NH0.LlxctPuZzZxksA28CLUoli0yROC_iU9sWV-2ZXtcw4c',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    
    // Escuchar cambios en la sesión
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // Redirigir al usuario cuando inicie sesión
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: supabase.auth.currentSession == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
