import 'package:cowork_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cowork_frontend/core/themes/app_theme.dart';
import 'package:cowork_frontend/injection/dependency_injection.dart';
import 'package:cowork_frontend/features/home/presentation/pages/home_page.dart';

void main() {
  // Configurar dependencias
  DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cowork Frontend',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const LoginPage(),
      // home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
