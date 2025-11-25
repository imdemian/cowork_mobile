// lib/features/reservations/presentation/pages/my_reservations_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas Activas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 QUERY SIMPLIFICADA - Sin el orderBy que causa problemas
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'confirmed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 🔥 FILTRAR MANUALMENTE LAS RESERVAS ACTIVAS (no expiradas)
          final now = DateTime.now();
          final activeDocs = snapshot.data!.docs.where((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;

              // 🔥 MANEJO SEGURO DE TIMESTAMP
              final expiresAtData = data['expiresAt'];
              if (expiresAtData == null) {
                debugPrint('⚠️ Reservation ${doc.id} has null expiresAt');
                return false;
              }

              final expiresAt = (expiresAtData as Timestamp).toDate();
              return expiresAt.isAfter(now);
            } catch (e) {
              debugPrint('❌ Error filtering reservation ${doc.id}: $e');
              return false;
            }
          }).toList();

          // 🔥 ORDENAR MANUALMENTE POR FECHA DE EXPIRACIÓN
          activeDocs.sort((a, b) {
            final aExpires =
                ((a.data() as Map<String, dynamic>)['expiresAt'] as Timestamp)
                    .toDate();
            final bExpires =
                ((b.data() as Map<String, dynamic>)['expiresAt'] as Timestamp)
                    .toDate();
            return aExpires.compareTo(bExpires);
          });

          if (activeDocs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeDocs.length,
            itemBuilder: (context, index) {
              final doc = activeDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final reservationId = doc.id;

              return _buildReservationCard(data, reservationId);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'No tienes reservas activas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Cuando reserves un espacio,\naparecerá aquí tu llave digital',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.search),
            label: const Text('Buscar espacios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(
    Map<String, dynamic> data,
    String reservationId,
  ) {
    final spaceName = data['spaceName'] ?? 'Espacio desconocido';
    String accessCode = data['accessCode'] ?? '';
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    final date = data['date'] ?? 'Hoy';
    final slot = data['slot'] ?? 'Todo el día';

    // 🔥 SI accessCode ES NULL O VACÍO, GENERAR UNO NUEVO
    if (accessCode.isEmpty || accessCode == 'null') {
      accessCode = _generateCode();
      // Actualizar en Firebase en background
      _updateAccessCode(reservationId, accessCode);
    }

    // Tiempo restante
    final Duration remaining = expiresAt.difference(DateTime.now());
    final bool isExpiringSoon = remaining.inMinutes < 10;

    // Datos para el QR
    final Map<String, dynamic> qrData = {
      'reservationId': reservationId,
      'spaceName': spaceName,
      'accessCode': accessCode,
      'userId': userId,
      'date': date,
      'slot': slot,
      'expiresAt': expiresAt.toIso8601String(),
    };

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título y fecha
            Row(
              children: [
                const Icon(
                  Icons.business_center,
                  size: 32,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spaceName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$date • $slot',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpiringSoon ? Icons.access_time : Icons.check_circle,
                  color: isExpiringSoon ? Colors.orange : Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // QR GIGANTE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: QrImageView(
                data: jsonEncode(qrData),
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Código de acceso
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Código de acceso',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    accessCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tiempo restante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isExpiringSoon
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExpiringSoon ? Colors.orange : Colors.green,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isExpiringSoon ? Icons.warning : Icons.timer,
                    color: isExpiringSoon ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      isExpiringSoon
                          ? '¡Expira en ${remaining.inMinutes} minutos!'
                          : 'Válido por ${remaining.inHours}h ${remaining.inMinutes % 60}m',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isExpiringSoon
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón renovar (solo si está cerca de expirar)
            if (isExpiringSoon)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _renewCode(reservationId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Renovar Código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔥 ACTUALIZA EL ACCESS CODE EN FIREBASE
  Future<void> _updateAccessCode(String reservationId, String code) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'accessCode': code});
    } catch (e) {
      debugPrint('Error updating access code: $e');
    }
  }

  /// 🔥 RENUEVA EL CÓDIGO Y EXTIENDE LA EXPIRACIÓN
  Future<void> _renewCode(String reservationId) async {
    try {
      final newExpiresAt = Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 2)),
      );
      final newCode = _generateCode();

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'accessCode': newCode, 'expiresAt': newExpiresAt});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Código renovado por 2 horas más!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al renovar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 🔥 GENERA UN CÓDIGO ÚNICO
  String _generateCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return '${now % 10000}'.padLeft(4, '0');
  }
}
