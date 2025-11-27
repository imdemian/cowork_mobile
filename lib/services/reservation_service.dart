// lib/services/reservation_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'reservations',
  );

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Lista de franjas horarias por defecto (hora inicio - hora fin)
  List<String> defaultSlots({int startHour = 8, int endHour = 20}) {
    final slots = <String>[];
    for (int h = startHour; h < endHour; h++) {
      final s =
          '${h.toString().padLeft(2, '0')}:00-${(h + 1).toString().padLeft(2, '0')}:00';
      slots.add(s);
    }
    return slots;
  }

  // Chequear si un espacio está disponible en una fecha/slot
  Future<bool> isSlotAvailable({
    required String spaceId,
    required String date, // yyyy-mm-dd
    required String slot,
  }) async {
    final q = await _col
        .where('spaceId', isEqualTo: spaceId)
        .where('date', isEqualTo: date)
        .where('slot', isEqualTo: slot)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    return q.docs.isEmpty;
  }

  // Crear reserva (si está disponible)
  Future<DocumentReference> createReservation({
    required String spaceId,
    required String spaceName,
    required String date,
    required String slot,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final available = await isSlotAvailable(
      spaceId: spaceId,
      date: date,
      slot: slot,
    );
    if (!available) throw Exception('Slot no disponible');

    final docRef = await _col.add({
      'spaceId': spaceId,
      'spaceName': spaceName,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'date': date,
      'slot': slot,
      'status': 'confirmed',
      'accessCode': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef;
  }

  // Generar y guardar código de acceso
  Future<String> generateAccessCode(String reservationId) async {
    try {
      final String code = _generateCode();

      final Timestamp expiresAt = Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 1)),
      );

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({
            'accessCode': code,
            'expiresAt': expiresAt,
            'status': 'confirmed',
          });

      return code;
    } catch (e) {
      print("Error generando accessCode: $e");
      rethrow;
    }
  }

  String _generateCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return '${now % 10000}'.padLeft(4, '0');
  }

  // Alternativa: Código numérico de 6 dígitos
  Future<String> generateNumericAccessCode(String reservationId) async {
    final random = Random.secure();
    final code = (random.nextInt(900000) + 100000).toString();

    // 💡 GUARDAR EL CÓDIGO NUMÉRICO
    await _col.doc(reservationId).update({'accessCode': code});

    print(
      'Generated numeric code: $code and SAVED for reservation: $reservationId',
    );

    return code;
  }

  String _random6Digit() {
    final rnd = Random();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  // 2. NUEVO: Obtener la última reserva activa para un espacio (consulta optimizada)
  Future<ReservationModel?> getLatestReservationForSpace(String spaceId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    try {
      final snapshot = await _col
          .where('userId', isEqualTo: userId)
          .where('spaceId', isEqualTo: spaceId)
          .where(
            'status',
            whereIn: ['pending', 'confirmed'],
          ) // Solo reservas activas
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // 🔥 CORREGIDO: Usar fromFirestore
        return ReservationModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error al cargar la última reserva: $e');
      return null;
    }
  }

  // Obtener reservas por espacio/fecha (útil para mostrar ocupación)
  Future<List<ReservationModel>> getReservationsForSpaceAndDate(
    String spaceId,
    String date,
  ) async {
    final q = await _col
        .where('spaceId', isEqualTo: spaceId)
        .where('date', isEqualTo: date)
        // Se asume que no necesitas filtrar por slot aquí si no es parámetro
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    // 🔥 CORREGIDO: Usar fromFirestore
    return q.docs.map((d) => ReservationModel.fromFirestore(d)).toList();
  }

  // Obtener reservas del usuario (MANTENER ESTE POR SI SE USA EN OTRO LADO)
  Future<List<ReservationModel>> getUserReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final q = await _col
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    // 🔥 CORREGIDO: Usar fromFirestore
    return q.docs.map((d) => ReservationModel.fromFirestore(d)).toList();
  }

  // Admin: obtener todas las reservas
  Future<List<ReservationModel>> getAllReservations() async {
    final q = await _col.orderBy('createdAt', descending: true).get();

    // 🔥 CORREGIDO: Usar fromFirestore
    return q.docs.map((d) => ReservationModel.fromFirestore(d)).toList();
  }

  // Cancelar reserva
  Future<void> cancelReservation(String reservationId) async {
    await _col.doc(reservationId).update({'status': 'cancelled'});
  }
}
