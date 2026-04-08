import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/api.dart';
import 'theme.dart';

/// Ponto de entrada do aplicativo. Inicializa o Flutter e executa [MyApp].
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Constrói o widget raiz da aplicação com tema e rota inicial (LoginScreen).
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Clientes',
      theme: buildAppTheme(),
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
