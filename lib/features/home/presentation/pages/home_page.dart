// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cowork_frontend/features/home/presentation/pages/search_page.dart';
import 'package:cowork_frontend/features/home/presentation/pages/favorites_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/profile_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/privacy_policy_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/data_protection_page.dart';
import 'package:cowork_frontend/services/google_sign_in_service.dart';
import '../../../../models/space_model.dart';
import '../../../../services/space_service.dart';
import '../pages/space_detail_page.dart';
import '../../../../services/favorites_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Las 4 pestañas principales
  final List<Widget> _pages = const [
    HomeContent(), // Aquí va el contenido del inicio
    SearchPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cowork Spaces'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleSignInService.signOut();
              if (mounted) {
                // Asumiendo que '/login' existe en las rutas de tu MaterialApp
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, user), // Drawer con datos del usuario
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  // Drawer personalizado con foto y nombre del usuario
  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(
              user?.displayName ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? 'email@ejemplo.com'),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
              backgroundColor: Colors.white,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Mis Reservas'),
            onTap: () => _showComingSoon(),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de Reservas'),
            onTap: () => _showComingSoon(),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Métodos de Pago'),
            onTap: () => _showComingSoon(),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () => _showComingSoon(),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda y Soporte'),
            onTap: () => _showComingSoon(),
          ),
          const Divider(),

          // Políticas
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidad'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Protección de Datos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataProtectionPage()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Cowork Mobile',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.business_center, size: 50),
                children: const [
                  Text('App para reservar espacios de coworking'),
                  SizedBox(height: 10),
                  Text('© 2025 Cowork Mobile'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// CONTENIDO PRINCIPAL DEL INICIO
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // Método auxiliar _miniChip reubicado DENTRO de la clase HomeContent
  Widget _miniChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpaceModel>>(
      future: SpaceService().getAvailableSpaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Utiliza un patrón de error más limpio
        if (snapshot.hasError) {
          // Asegúrate de que snapshot.error sea un String o convertirlo.
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }

        final spaces = snapshot.data ?? [];

        if (spaces.isEmpty) {
          return const Center(child: Text('No hay espacios disponibles'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: spaces.length,
          itemBuilder: (context, index) {
            final space = spaces[index];

            return Card(
              elevation: 6,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpaceDetailPage(space: space),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        space.imageUrl.isNotEmpty
                            ? space.imageUrl
                            : 'https://via.placeholder.com/400',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            space.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Etiquetas + Corazón + Estrellas
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _miniChip(
                                      Icons.location_on,
                                      'Centro',
                                      Colors.red,
                                    ),
                                    _miniChip(
                                      Icons.meeting_room,
                                      'Sala',
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ),

                              // CORAZÓN REAL CON FAVORITOS
                              StreamBuilder<bool>(
                                stream: FavoritesService().isFavorite(space.id),
                                builder: (context, snapshot) {
                                  final bool isFavorite =
                                      snapshot.data ?? false;

                                  return IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey<bool>(isFavorite),
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await FavoritesService().toggleFavorite(
                                        space.id,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFavorite
                                                ? 'Eliminado de favoritos'
                                                : 'Añadido a favoritos',
                                          ),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: isFavorite
                                              ? Colors.grey
                                              : Colors.pink,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              // Calificación (Se agregó un SizedBox para separar del ícono)
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    space.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Precio + Botón
                          Row(
                            children: [
                              Text(
                                // FIX: Usar .toStringAsFixed(2) para mejor formato decimal
                                '\$${space.pricePerHour.toStringAsFixed(2)}/hora',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SpaceDetailPage(space: space),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.remove_red_eye,
                                  size: 18,
                                ),
                                label: const Text('Ver detalles'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
// Widget _buildSpaceCard y NavigationService se mantienen aquí abajo:

Widget _buildSpaceCard(
  String name,
  double price,
  String rating,
  IconData icon,
) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.indigo.shade50,
        child: Icon(icon, size: 30, color: Colors.indigo),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('$rating • Abierto ahora'),
          Text(
            '\$${price.toStringAsFixed(2)} / hora',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () {
        // Aquí irás al detalle del espacio
        ScaffoldMessenger.of(
          NavigationService.navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text('Abriendo $name...')));
      },
    ),
  );
}

// Para usar en SnackBars sin contexto
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
