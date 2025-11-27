// lib/models/favorite_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id; // Que será el spaceId
  final String spaceId;
  final Timestamp addedAt;

  FavoriteModel({
    required this.id,
    required this.spaceId,
    required this.addedAt,
  });

  factory FavoriteModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Aseguramos que el ID del documento es el ID del espacio
    final id = doc.id;

    return FavoriteModel(
      id: id,
      spaceId:
          data?['spaceId'] ?? id, // Generalmente será el mismo que el doc.id
      addedAt: data?['addedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'spaceId': spaceId, 'addedAt': addedAt};
  }
}
