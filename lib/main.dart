import 'package:flutter/material.dart';
import 'package:cowork_frontend/core/themes/app_theme.dart';
import 'package:cowork_frontend/injection/dependency_injection.dart';
import 'package:cowork_frontend/features/home/presentation/pages/home_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cowork_frontend/features/home/presentation/pages/search_page.dart';
import 'package:cowork_frontend/features/home/presentation/pages/favorites_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/profile_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/privacy_policy_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/data_protection_page.dart';

void main() {
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/profile': (context) => const ProfilePage(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/data-protection': (context) => const DataProtectionPage(),
      },
    );
  }
}
