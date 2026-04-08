import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/theme.dart';
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
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Envia as credenciais para a API e, em caso de sucesso, armazena o token
  /// JWT em [authToken] e navega para [ClientsScreen]. Em caso de falha,
  /// exibe a mensagem de erro na tela.
  bool _isValidEmail(String email) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() => error = 'Informe um e-mail válido.');
      return;
    }
    if (password.isEmpty) {
      setState(() => error = 'Informe a senha.');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final response = await apiPost('/users/login', {
        'email': email,
        'password': password,
      });

      if (response['token'] != null) {
        authToken = response['token'];
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientsScreen()),
        );
      } else {
        setState(() {
          error = 'Email ou senha inválidos';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  /// Constrói a tela de login com campos de e-mail e senha, botão de acesso
  /// e área de exibição de erro.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gestão de Clientes',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Acesse sua conta',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loading ? null : handleLogin,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        error,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
