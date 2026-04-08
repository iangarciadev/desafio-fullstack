import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Clientes',
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}
