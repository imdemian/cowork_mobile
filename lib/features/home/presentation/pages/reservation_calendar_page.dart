// lib/features/home/presentation/pages/reservation_calendar_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/space_model.dart';
import '../../../../services/reservation_service.dart';

class ReservationCalendarPage extends StatefulWidget {
  final SpaceModel space;
  const ReservationCalendarPage({super.key, required this.space});

  @override
  State<ReservationCalendarPage> createState() =>
      _ReservationCalendarPageState();
}

class _ReservationCalendarPageState extends State<ReservationCalendarPage> {
  DateTime selectedDay = DateTime.now();
  String? selectedSlot;
  final ReservationService _reservationService = ReservationService();
  List<String> slots = [];
  Map<String, bool> slotAvailability = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    slots = _reservationService.defaultSlots();
    _refreshAvailability();
  }

  Future<void> _refreshAvailability() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
    final reservations = await _reservationService
        .getReservationsForSpaceAndDate(widget.space.id, dateStr);
    final occupiedSlots = reservations.map((r) => r.slot).toSet();

    setState(() {
      slotAvailability = {for (final s in slots) s: !occupiedSlots.contains(s)};

      // Si el slot seleccionado ya no está disponible, deseleccionarlo
      if (selectedSlot != null && slotAvailability[selectedSlot!] == false) {
        selectedSlot = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.space.name}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📅 CALENDARIO
                CalendarDatePicker(
                  initialDate: selectedDay,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (d) {
                    setState(() => selectedDay = d);
                    _refreshAvailability();
                  },
                ),

                const Divider(height: 1),
                const SizedBox(height: 16),

                // 📌 TÍTULO DE HORARIOS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        'Selecciona un horario',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ⏰ SLOTS DISPONIBLES
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((s) {
                        final available = slotAvailability[s] ?? true;
                        final isSelected = selectedSlot == s;

                        return ChoiceChip(
                          label: Text(
                            s,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: available
                              ? (v) {
                                  setState(() {
                                    selectedSlot = v ? s : null;
                                  });
                                }
                              : null,
                          backgroundColor: available
                              ? Colors.grey[200]
                              : Colors.red[100],
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (available ? Colors.black : Colors.red),
                          ),
                          disabledColor: Colors.red[100],
                          avatar: available
                              ? null
                              : const Icon(
                                  Icons.block,
                                  size: 16,
                                  color: Colors.red,
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 📊 INFO SELECCIÓN
                if (selectedSlot != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.indigo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen de tu reserva:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(selectedDay)} • $selectedSlot',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Precio: \$${widget.space.pricePerHour.toStringAsFixed(2)}/hora',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ✅ BOTÓN CONFIRMAR
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedSlot == null
                          ? null
                          : _confirmReservation,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirmar Reserva'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// 🔥 CONFIRMA LA RESERVA Y LA GUARDA EN FIREBASE
  Future<void> _confirmReservation() async {
    if (selectedSlot == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Debes iniciar sesión para reservar');
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);

      // 1️⃣ Calcular expiresAt basado en el horario seleccionado
      final DateTime expiresAt = _calculateExpiresAt(
        selectedDay,
        selectedSlot!,
      );

      // 2️⃣ Crear la reservación en Firebase
      final docRef = await FirebaseFirestore.instance
          .collection('reservations')
          .add({
            'userId': user.uid,
            'userEmail': user.email,
            'spaceId': widget.space.id,
            'spaceName': widget.space.name,
            'date': dateStr,
            'slot': selectedSlot,
            'status': 'confirmed',
            'accessCode':
                '', // 🔥 VACÍO - se generará al abrir la llave digital
            'createdAt':
                Timestamp.now(), // 🔥 USAR Timestamp.now() en lugar de serverTimestamp
            'expiresAt': Timestamp.fromDate(expiresAt),
          });

      if (!mounted) return;

      // 3️⃣ Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('¡Reserva creada exitosamente!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 4️⃣ Esperar un momento y regresar con TRUE
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // 🔥 RETORNAR TRUE PARA QUE SpaceDetailPage RECARGUE EL ESTADO
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error creating reservation: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Recargar disponibilidad por si el slot fue tomado
      await _refreshAvailability();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _calculateExpiresAt(DateTime date, String slot) {
    final parts = slot.split('-');
    if (parts.length != 2)
      return DateTime(
        date.year,
        date.month,
        date.day,
      ).add(const Duration(hours: 2));

    final endTime = parts[1].trim();
    final timeParts = endTime.split(':');

    if (timeParts.length != 2)
      return DateTime(
        date.year,
        date.month,
        date.day,
      ).add(const Duration(hours: 2));

    final endHour = int.tryParse(timeParts[0]) ?? 23;
    final endMinute = int.tryParse(timeParts[1]) ?? 0;

    return DateTime(date.year, date.month, date.day, endHour, endMinute);
  }
}
