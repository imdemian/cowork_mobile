// lib/features/auth/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/privacy_policy_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/data_protection_page.dart';
import 'package:cowork_frontend/services/google_sign_in_service.dart';

// ← NUEVAS PÁGINAS QUE VAMOS A USAR
import 'package:cowork_frontend/features/home/presentation/pages/favorites_page.dart';
import 'package:cowork_frontend/features/home/presentation/pages/my_reservations_page.dart'; // ← CREAREMOS ESTA

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  int _favoriteCount = 0;
  int _activeReservations = 0;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _user = user);

    // Cargar favoritos
    final favSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();
    _favoriteCount = favSnapshot.size;

    // Cargar reservas activas (confirmadas y no expiradas)
    final now = Timestamp.now();
    final resSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'confirmed')
        .where('expiresAt', isGreaterThan: now)
        .get();
    _activeReservations = resSnapshot.size;

    // Cargar rating del usuario (si existe)
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    _userRating = (userDoc.data()?['rating'] ?? 0.0).toDouble();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = _user!.displayName ?? 'Usuario';
    final email = _user!.email ?? 'No disponible';
    final photoURL = _user!.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header del perfil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.indigo.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: photoURL != null
                          ? NetworkImage(photoURL)
                          : null,
                      backgroundColor: Colors.white,
                      child: photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.indigo,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Estadísticas REALES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        _activeReservations.toString(),
                        'Reservas Activas',
                        Icons.qr_code_2,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        _favoriteCount.toString(),
                        'Favoritos',
                        Icons.favorite,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        _userRating.toStringAsFixed(1),
                        'Rating',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Menú de opciones
              _buildMenuSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuGroup('Mi Cuenta', [
          _buildMenuItem(
            context,
            Icons.qr_code_scanner,
            'Mis Reservas Activas',
            'Ver códigos QR vigentes',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyReservationsPage()),
            ),
          ),
          _buildMenuItem(
            context,
            Icons.favorite,
            'Mis Favoritos',
            '$_favoriteCount espacios guardados',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
          _buildMenuItem(
            context,
            Icons.history,
            'Historial de Reservas',
            'Reservas pasadas y canceladas',
            () => _showComingSoon('Historial de Reservas'),
          ),
        ]),

        const SizedBox(height: 16),

        _buildMenuGroup('Pagos y Facturación', [
          _buildMenuItem(
            context,
            Icons.payment,
            'Métodos de Pago',
            'Tarjetas guardadas',
            () => _showComingSoon('Métodos de Pago'),
          ),
          _buildMenuItem(
            context,
            Icons.receipt_long,
            'Facturas',
            'Descargar recibos',
            () => _showComingSoon('Facturas'),
          ),
        ]),

        const SizedBox(height: 16),

        _buildMenuGroup('Configuración', [
          _buildMenuItem(
            context,
            Icons.notifications,
            'Notificaciones',
            'Alertas y recordatorios',
            () => _showComingSoon('Notificaciones'),
          ),
          _buildMenuItem(
            context,
            Icons.language,
            'Idioma',
            'Español',
            () => _showComingSoon('Idioma'),
          ),
          _buildMenuItem(
            context,
            Icons.dark_mode,
            'Tema Oscuro',
            'Desactivado',
            () => _showComingSoon('Tema'),
          ),
        ]),

        const SizedBox(height: 16),

        _buildMenuGroup('Legal', [
          _buildMenuItem(
            context,
            Icons.privacy_tip,
            'Privacidad y Datos',
            'Políticas',
            () => _showPrivacyOptions(context),
          ),
          _buildMenuItem(
            context,
            Icons.help_outline,
            'Ayuda y Soporte',
            'Centro de ayuda',
            () => _showComingSoon('Ayuda'),
          ),
          _buildMenuItem(
            context,
            Icons.info,
            'Acerca de',
            'Cowork Mobile v1.0.0',
            () => _showAbout(),
          ),
        ]),

        const SizedBox(height: 30),

        // Botón cerrar sesión
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature - Próximamente')));
  }

  void _showPrivacyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Privacidad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Política de Privacidad'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Protección de Datos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataProtectionPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Cowork Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.business_center,
        size: 50,
        color: Colors.indigo,
      ),
      children: const [
        Text('La mejor app para reservar espacios de coworking'),
        SizedBox(height: 10),
        Text('© 2025 Cowork Mobile'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await GoogleSignInService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
