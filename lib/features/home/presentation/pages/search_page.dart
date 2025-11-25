// lib/features/home/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowork_frontend/models/space_model.dart';
import 'package:cowork_frontend/services/space_service.dart';
import 'package:cowork_frontend/services/favorites_service.dart';
import 'space_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Espacios'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, ubicación, tipo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),

          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', true),
                _buildFilterChip('Disponibles', false),
                _buildFilterChip('Mejor valorados', false),
                _buildFilterChip('Precio bajo', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Resultados
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildPopularCategories()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.indigo,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) {},
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPopularCategories() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Categorías populares',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Oficinas privadas',
          Icons.door_front_door,
          Colors.blue,
        ),
        _buildCategoryCard('Salas de reunión', Icons.groups, Colors.green),
        _buildCategoryCard(
          'Escritorios compartidos',
          Icons.desk,
          Colors.orange,
        ),
        _buildCategoryCard('Espacios creativos', Icons.palette, Colors.purple),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            _searchController.text = title;
            _searchQuery = title.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('spaces').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No se encontraron espacios'));
        }

        // Filtrar resultados
        final List<SpaceModel> allSpaces = snapshot.data!.docs
            .map(
              (doc) => SpaceModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();

        final filteredSpaces = allSpaces.where((space) {
          final query = _searchQuery;
          if (query.isEmpty) return true;

          return space.name.toLowerCase().contains(query) ||
              space.description.toLowerCase().contains(query) ||
              'centro'.contains(
                query,
              ) || // Puedes mejorar con campo real de ubicación
              'sala'.contains(query) ||
              'oficina'.contains(query) ||
              'escritorio'.contains(query);
        }).toList();

        if (filteredSpaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No se encontraron resultados para "$_searchQuery"'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredSpaces.length,
          itemBuilder: (context, index) {
            final space = filteredSpaces[index];
            return _buildSpaceCard(space);
          },
        );
      },
    );
  }

  Widget _buildSpaceCard(SpaceModel space) {
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                space.imageUrl.isNotEmpty
                    ? space.imageUrl
                    : 'https://via.placeholder.com/400',
                height: 160,
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
                      fontSize: 18,
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
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${space.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '\$${space.pricePerHour.toStringAsFixed(0)}/hora',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      // Corazón favorito
                      StreamBuilder<bool>(
                        stream: FavoritesService().isFavorite(space.id),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () =>
                                FavoritesService().toggleFavorite(space.id),
                          );
                        },
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
