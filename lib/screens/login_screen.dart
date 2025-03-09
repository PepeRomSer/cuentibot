import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cuentibot/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Corrección: Usamos OAuthProvider.google() en lugar de Provider.google
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);

      // Verifica si el usuario ha iniciado sesión después de autenticarse
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150), // Logo de la app
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión con Google'),
              onPressed: () => _signInWithGoogle(context),
            ),
          ],
        ),
      ),
    );
  }
}
