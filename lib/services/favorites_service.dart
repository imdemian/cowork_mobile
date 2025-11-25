// lib/services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ← NUEVO: Método seguro para obtener el UID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Solo si hay usuario logueado
  bool get _isLoggedIn => _userId != null;

  // Añadir o quitar favorito
  Future<void> toggleFavorite(String spaceId) async {
    if (!_isLoggedIn) return;

    final ref = _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(spaceId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'spaceId': spaceId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ¿Está en favoritos?
  Stream<bool> isFavorite(String spaceId) {
    if (!_isLoggedIn) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(spaceId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ← AQUÍ ESTABA EL ERROR: ahora protegido
  Stream<List<String>> getFavoriteSpaceIds() {
    if (!_isLoggedIn) {
      return Stream.value([]); // ← Devuelve lista vacía si no hay usuario
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
