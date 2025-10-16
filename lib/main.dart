import 'package:flutter/material.dart';
import 'package:cowork_frontend/core/themes/app_theme.dart';
import 'package:cowork_frontend/core/routes/app_routes.dart';
import 'package:cowork_frontend/injection/dependency_injection.dart';
import 'package:cowork_frontend/features/home/presentation/pages/home_page.dart';

// Importar todas las páginas
import 'package:cowork_frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cowork_frontend/core/navigation/main_navigation_page.dart';
import 'package:cowork_frontend/features/spaces/presentation/pages/space_detail_page.dart';

// Importar todas las páginas
import 'package:cowork_frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cowork_frontend/core/navigation/main_navigation_page.dart';
import 'package:cowork_frontend/features/spaces/presentation/pages/space_detail_page.dart';

void main() {
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWork',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      home: const HomePage(),
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const MainNavigationPage(),
        AppRoutes.spaceDetail: (context) => const SpaceDetailPage(),
      },
    );
  }
}