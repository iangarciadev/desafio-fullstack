import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';
import 'clients_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> handleLogin() async {
    final response = await apiPost('/users/login', {
      'email': emailController.text,
      'password': passwordController.text,
    });

    if (response['token'] != null) {
      authToken = response['token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientsScreen()),
      );
    } else {
      setState(() {
        error = 'Email ou senha inválidos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Entrar'),
            ),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}