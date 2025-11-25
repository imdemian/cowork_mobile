// lib/services/space_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/space_model.dart';

class SpaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SpaceModel>> getAvailableSpaces() async {
    try {
      final snapshot = await _firestore
          .collection('spaces')
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => SpaceModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error cargando espacios: $e');
      return [];
    }
  }

  // En lib/services/space_service.dart
  Future<List<SpaceModel>> getSpacesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _firestore
        .collection('spaces')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs
        .map((doc) => SpaceModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
