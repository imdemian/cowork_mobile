// lib/features/home/presentation/pages/digital_key_page.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../../../models/space_model.dart';

class DigitalKeyPage extends StatelessWidget {
  final SpaceModel space;
  final Map<String, dynamic> reservationData;

  const DigitalKeyPage({
    super.key,
    required this.space,
    required this.reservationData,
  });

  @override
  Widget build(BuildContext context) {
    final String accessCode = reservationData['accessCode'] ?? '0000';

    // 🔥 MANEJO SEGURO DE TIMESTAMP
    DateTime expiresAt;
    try {
      final expiresAtData = reservationData['expiresAt'];
      if (expiresAtData is Timestamp) {
        expiresAt = expiresAtData.toDate();
      } else if (expiresAtData is String) {
        expiresAt = DateTime.parse(expiresAtData);
      } else {
        expiresAt = DateTime.now().add(const Duration(hours: 2));
      }
    } catch (e) {
      debugPrint('Error parsing expiresAt: $e');
      expiresAt = DateTime.now().add(const Duration(hours: 2));
    }

    final String date = reservationData['date'] ?? 'Hoy';
    final String slot = reservationData['slot'] ?? 'Todo el día';

    // Tiempo restante
    final Duration remaining = expiresAt.difference(DateTime.now());
    final bool isExpiringSoon = remaining.inMinutes < 10;

    final Map<String, dynamic> qrData = {
      'spaceId': space.id,
      'spaceName': space.name,
      'accessCode': accessCode,
      'userId': reservationData['userId'],
      'generatedAt': DateTime.now().toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'date': date,
      'slot': slot,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Llave Digital'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Título
              Text('Acceso a:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                space.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$date • $slot',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // QR GRANDE Y BONITO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: jsonEncode(qrData),
                  version: QrVersions.auto,
                  size: 280,
                  gapless: false,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Código de texto
              Card(
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Código de acceso:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        accessCode,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tiempo restante
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpiringSoon ? Icons.warning : Icons.timer,
                      color: isExpiringSoon ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpiringSoon
                          ? '¡Expira en ${remaining.inMinutes} minutos!'
                          : 'Válido por ${remaining.inHours}h ${remaining.inMinutes % 60}m',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpiringSoon
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Instrucciones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cómo usar:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildInstruction(
                        'Muestra este QR en la entrada del coworking',
                      ),
                      _buildInstruction(
                        'También puedes decir el código: $accessCode',
                      ),
                      _buildInstruction(
                        'Válido para $date en el horario $slot',
                      ),
                      _buildInstruction('Solo para ${space.name}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
