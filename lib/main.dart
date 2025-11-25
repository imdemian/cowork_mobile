// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/sign_up_page.dart';
import 'package:cowork_frontend/features/home/presentation/pages/home_page.dart';
import 'package:cowork_frontend/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- FALTABA ESTE (Vital)
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- FALTABA ESTE (Para consultar admin)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWork Spaces',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(), // Aquí está la magia
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const HomePage(),
        '/admin': (context) => const AdminDashboardPage(),
      },
    );
  }
}

// NUEVO WIDGET: Escucha el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Está cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuario autenticado
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Verificar si es admin (puedes usar un campo en Firestore o email)
          return FutureBuilder<bool>(
            future: _isAdmin(user.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool isAdmin = adminSnapshot.data ?? false;

              return isAdmin
                  ? const AdminDashboardPage()
                  : const HomePage(); // Aquí va al home normal
            },
          );
        }

        // No hay usuario → Login
        return const LoginPage();
      },
    );
  }

  // Función para verificar si es admin (ajusta según tu lógica)
  Future<bool> _isAdmin(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      return data['role'] == 'admin' ||
          data['isAdmin'] == true ||
          data['email'] == 'admin@cowork.com'; // o tu lógica
    } catch (e) {
      return false;
    }
  }
}
