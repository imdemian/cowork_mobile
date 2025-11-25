// lib/features/admin/presentation/pages/admin_reservations_page.dart
import 'package:flutter/material.dart';
import '../../../../models/reservation_model.dart';
import '../../../../services/reservation_service.dart';

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  final ReservationService _reservationService = ReservationService();
  late Future<List<ReservationModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _reservationService.getAllReservations();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _reservationService.getAllReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas (Admin)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<ReservationModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final items = snap.data ?? [];
          if (items.isEmpty)
            return const Center(child: Text('No hay reservas'));

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final r = items[i];
              return ListTile(
                title: Text('${r.spaceName} • ${r.date} ${r.slot}'),
                subtitle: Text('${r.userEmail} • ${r.status}'),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: r.status == 'cancelled'
                      ? null
                      : () async {
                          await _reservationService.cancelReservation(r.id);
                          _refresh();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reservación cancelada'),
                            ),
                          );
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
