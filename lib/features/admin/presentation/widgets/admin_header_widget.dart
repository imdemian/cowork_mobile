import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- 1. Agrega este import

class AdminHeaderWidget extends StatelessWidget {
  const AdminHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Obtenemos el usuario actual directamente de Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, Admin!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              // 3. Usamos user?.email (el ? es por si fuera nulo)
              'Cuenta: ${user?.email ?? "Desconocido"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // 4. Usamos la fecha de creación que viene en los metadatos de Firebase
              'Miembro desde: ${user?.metadata.creationTime.toString().split(' ')[0] ?? "Hoy"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
