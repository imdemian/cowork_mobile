// lib/features/admin/presentation/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Añadir esta importación
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../services/google_sign_in_service.dart';
import '../../../admin/presentation/pages/digital_key_scanner_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _clientsFuture;
  int _currentIndex = 0;
  // 🔥 OBTENER EL USUARIO ACTUAL PARA EL DRAWER
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Páginas del admin
  late final List<Widget> _pages; // Se inicializa en initState

  @override
  void initState() {
    super.initState();
    _clientsFuture = _userService.getAllClients();

    _pages = [
      _AdminHomeContent(
        clientsFuture: _clientsFuture,
        onRefresh: _refreshClients,
      ),
      const QrScannerPage(),
      _AdminStatsPage(),
    ];
  }

  void _refreshClients() {
    setState(() {
      _clientsFuture = _userService.getAllClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshClients,
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Escanear QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    // 🔥 USAR DATOS REALES DEL USUARIO LOGUEADO
    final user = _currentUser;
    final displayName = user?.displayName ?? 'Administrador';
    final email = user?.email ?? 'admin@cowork.com';
    final photoUrl = user?.photoURL;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Icon(
                          Icons.admin_panel_settings,
                          size: 35,
                          color: Theme.of(
                            context,
                          ).primaryColor, // Usar color primario
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Resumen'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room),
            title: const Text('Reservas'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.workspaces),
            title: const Text('Espacios'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Escanear QR'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              await GoogleSignInService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// -------------------------------------------------------------
// CONTENIDO PRINCIPAL DEL ADMIN
class _AdminHomeContent extends StatelessWidget {
  final Future<List<UserModel>> clientsFuture;
  final VoidCallback onRefresh;

  const _AdminHomeContent({
    required this.clientsFuture,
    required this.onRefresh,
  });

  // 🔥 Función auxiliar para el chip, movida aquí
  Widget _buildStatusChip(String role) {
    Color color;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
        color = Colors.red;
        label = 'Admin';
        break;
      case 'premium':
        color = Colors.amber;
        label = 'Premium';
        break;
      default:
        color = Colors.blue;
        label = 'Cliente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de estadísticas
            _buildAdminSummaryCards(context),
            const SizedBox(height: 24),

            // Sección de clientes recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clientes Recientes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a vista completa de clientes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ver todos los clientes')),
                    );
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de clientes
            FutureBuilder<List<UserModel>>(
              future: clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final clients = snapshot.data ?? [];

                if (clients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay clientes registrados aún',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // === AQUÍ SE MUESTRAN LOS CLIENTES ===
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];

                    return Card(
                      // Eliminé el margin horizontal aquí para usar el padding del SingleChildScrollView
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(client.displayName ?? "Sin nombre"),
                        subtitle: Text(client.email),
                        // 🔥 USAR EL WIDGET CHIP ESTILIZADO
                        trailing: _buildStatusChip(client.role),
                      ),
                    );
                  },
                ); // CIERRE CORRECTO del ListView.builder
              }, // CIERRE CORRECTO del FutureBuilder builder
            ), // CIERRE CORRECTO del FutureBuilder
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            label: "Clientes",
            value: "152",
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.meeting_room,
            label: "Reservas Hoy",
            value: "23",
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.workspaces,
            label: "Espacios",
            value: "12",
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 38),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} // CIERRE CORRECTO de _AdminHomeContent

// -------------------------------------------------------------
// PÁGINA DE ESTADÍSTICAS
class _AdminStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Estadísticas Generales',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatDetailCard(
          context,
          'Ingresos del Mes',
          '\$45,230',
          Icons.attach_money,
          Colors.green,
          '+12% vs mes anterior',
        ),
        _buildStatDetailCard(
          context,
          'Reservas Totales',
          '1,234',
          Icons.calendar_today,
          Colors.blue,
          '89 reservas esta semana',
        ),
        _buildStatDetailCard(
          context,
          'Tasa de Ocupación',
          '78%',
          Icons.show_chart,
          Colors.orange,
          '+5% vs semana anterior',
        ),
        _buildStatDetailCard(
          context,
          'Clientes Activos',
          '452',
          Icons.people,
          Colors.purple,
          '23 nuevos este mes',
        ),
      ],
    );
  }

  Widget _buildStatDetailCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
