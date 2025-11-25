import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../pages/digital_key_page.dart';
import '../../../../models/space_model.dart';
import '../../../../features/home/presentation/pages/reservation_calendar_page.dart';

class SpaceDetailPage extends StatefulWidget {
  final SpaceModel space;
  const SpaceDetailPage({super.key, required this.space});

  @override
  State<SpaceDetailPage> createState() => _SpaceDetailPageState();
}

class _SpaceDetailPageState extends State<SpaceDetailPage> {
  bool hasReservation = false;
  bool isLoading = true;
  String? reservationId;
  Map<String, dynamic>? reservationData;

  @override
  void initState() {
    super.initState();
    _checkExistingReservation();
  }

  /// 🔥 VERIFICA SI YA EXISTE UNA RESERVA ACTIVA
  Future<void> _checkExistingReservation() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      debugPrint(
        '🔍 Checking reservations for userId: $userId, spaceId: ${widget.space.id}',
      );

      // 🔥 QUERY SIMPLIFICADA - Sin where de expiresAt
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .where('spaceId', isEqualTo: widget.space.id)
          .where('status', isEqualTo: 'confirmed')
          .get();

      debugPrint('📊 Found ${snapshot.docs.length} total reservations');

      // 🔥 FILTRAR MANUALMENTE las que NO han expirado
      final now = DateTime.now();
      DocumentSnapshot? activeReservation;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();

        debugPrint('📅 Reservation ${doc.id}: expires at $expiresAt');

        if (expiresAt.isAfter(now)) {
          activeReservation = doc;
          debugPrint('✅ Active reservation found!');
          break;
        }
      }

      if (activeReservation != null) {
        final data = activeReservation.data() as Map<String, dynamic>;

        debugPrint('✅ Using reservation: ${activeReservation.id}');
        debugPrint('📅 Date: ${data['date']}, Slot: ${data['slot']}');

        setState(() {
          hasReservation = true;
          reservationId = activeReservation!.id;
          reservationData = data;
        });
      } else {
        debugPrint('❌ No active reservations found');
        setState(() {
          hasReservation = false;
          reservationId = null;
          reservationData = null;
        });
      }
    } catch (e) {
      debugPrint('❗ Error checking reservation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar reservas: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Encabezado con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(space.name),
              background: Image.network(
                space.imageUrl.isNotEmpty
                    ? space.imageUrl
                    : 'https://via.placeholder.com/400',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chips + rating
                        Row(
                          children: [
                            _buildChip(
                              Icons.meeting_room,
                              "Sala",
                              Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            _buildChip(Icons.location_on, "Centro", Colors.red),
                            const Spacer(),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "4.9 (128)",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Descripción
                        Text(
                          space.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),

                        const SizedBox(height: 20),

                        // Características
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeature(
                              Icons.people,
                              '${space.capacity} personas',
                            ),
                            _buildFeature(Icons.wifi, 'WiFi 500MB'),
                            _buildFeature(Icons.coffee, 'Café gratis'),
                            _buildFeature(Icons.tv, 'Proyector'),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Precio bonito
                        Row(
                          children: [
                            Text(
                              '\$${space.pricePerHour.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/hora',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // 🔥 BANNER DE RESERVA ACTIVA
                        if (hasReservation && reservationData != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '¡Tienes una reserva activa!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${reservationData!['date']} • ${reservationData!['slot']}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Botones principales
                        Row(
                          children: [
                            // Ver disponibilidad (calendario futuro)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _openCalendar(),
                                child: const Text("Ver disponibilidad"),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // GENERAR ACCESO
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: hasReservation
                                    ? () => _openDigitalKey()
                                    : null,
                                icon: const Icon(Icons.key),
                                label: const Text("Generar Acceso"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // CHIPS (bonitos)
  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 28),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  /// 🔥 ABRE EL CALENDARIO Y ACTUALIZA ESTADO
  void _openCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationCalendarPage(space: widget.space),
      ),
    );

    // Si se creó una reserva, recargar estado
    if (result == true) {
      _checkExistingReservation();
    }
  }

  /// 🔥 GENERA ACCESSCODE SI ES NULL Y ABRE LA LLAVE DIGITAL
  Future<void> _openDigitalKey() async {
    if (reservationId == null) return;

    try {
      // 1. Obtener el documento actual
      final docRef = FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId);

      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();

      if (data == null) return;

      String accessCode = data['accessCode'];

      // 2. Si accessCode es null, generar uno nuevo
      if (accessCode.isEmpty || accessCode == 'null') {
        accessCode = _generateAccessCode();
        await docRef.update({'accessCode': accessCode});

        setState(() {
          reservationData!['accessCode'] = accessCode;
        });
      }

      // 3. Abrir la página de llave digital
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DigitalKeyPage(
              space: widget.space,
              reservationData: reservationData!,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening digital key: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 🔥 GENERA UN CÓDIGO DE ACCESO ÚNICO
  String _generateAccessCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now % 10000).toString().padLeft(4, '0');
    return '${random}CWK';
  }
}
