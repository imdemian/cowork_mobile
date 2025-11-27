// lib/features/home/presentation/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:cowork_frontend/models/space_model.dart';
import 'package:cowork_frontend/services/favorites_service.dart';
import 'package:cowork_frontend/services/space_service.dart';
import 'space_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<String>>(
        stream: FavoritesService().getFavoriteSpaceIds(),
        builder: (context, snapshot) {
          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = snapshot.data ?? [];

          // Sin favoritos
          if (favoriteIds.isEmpty) {
            return _buildEmptyState(context);
          }

          // Cargar los espacios reales desde Firestore
          return FutureBuilder<List<SpaceModel>>(
            future: SpaceService().getSpacesByIds(favoriteIds),
            builder: (context, spaceSnapshot) {
              if (spaceSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final spaces = spaceSnapshot.data ?? [];

              if (spaces.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: spaces.length,
                itemBuilder: (context, index) {
                  final space = spaces[index];
                  return _buildFavoriteCard(context, space);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toca el corazón en cualquier espacio para guardarlo aquí',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.search),
            label: const Text('Explorar espacios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, SpaceModel space) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SpaceDetailPage(space: space)),
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Centro Ciudad',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      // Corazón para quitar
                      StreamBuilder<bool>(
                        stream: FavoritesService().isFavorite(space.id),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                            onPressed: () async {
                              await FavoritesService().toggleFavorite(space.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFav
                                        ? 'Eliminado de favoritos'
                                        : 'Añadido a favoritos',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
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
                            builder: (_) => SpaceDetailPage(space: space),
                          ),
                        ),
                        icon: const Icon(Icons.remove_red_eye, size: 18),
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
  }
}
