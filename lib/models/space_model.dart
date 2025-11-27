// lib/models/space_model.dart
class SpaceModel {
  final String id;
  final String name;
  final String description;
  final double pricePerHour;
  final int capacity;
  final String imageUrl;
  final bool isAvailable;
  final double rating;

  SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.capacity,
    required this.imageUrl,
    this.isAvailable = true,
    required this.rating,
  });

  factory SpaceModel.fromFirestore(Map<String, dynamic> data, String id) {
    // 1. Manejo del rating: Asegura que siempre sea un double (int o double)
    final dynamic ratingValue = data['rating'];

    double finalRating;
    if (ratingValue is int) {
      // Si Firestore lo envió como entero (ej: 4), conviértelo a double (4.0)
      finalRating = ratingValue.toDouble();
    } else if (ratingValue is double) {
      // Si ya es un double (ej: 4.9), úsalo directamente.
      finalRating = ratingValue;
    } else {
      // Si es nulo o de otro tipo, usa el valor por defecto 0.0
      finalRating = 0.0;
    }

    // 2. Retorna la nueva instancia de SpaceModel
    return SpaceModel(
      id: id,
      name: data['name'] ?? 'Espacio sin nombre',
      description: data['description'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      // 3. Asigna el valor seguro y convertido
      rating: finalRating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'rating': rating,
    };
  }
}
