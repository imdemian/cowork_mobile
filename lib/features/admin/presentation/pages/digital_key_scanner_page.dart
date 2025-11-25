// lib/features/qr_scanner/presentation/pages/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    // autoStart: true, // por defecto ya inicia
  );

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Acceso'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Botón de linterna (funciona en la versión nueva)
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_off);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cámara
          MobileScanner(controller: controller, onDetect: _onDetect),

          // Marco cuadrado centrado
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Texto guía
          const Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Text(
              'Apunta el código QR dentro del marco',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) {
      _isProcessing = false;
      return;
    }

    final String code = barcode.rawValue!;
    await _validateQR(code);

    _isProcessing = false;
  }

  Future<void> _validateQR(String code) async {
    try {
      final Map<String, dynamic> data = jsonDecode(code);

      final String spaceName = data['spaceName'] ?? 'Espacio desconocido';
      final String accessCode = data['accessCode'] ?? 'N/A';
      final String expiresAtStr = data['expiresAt'];
      final DateTime expiresAt = DateTime.parse(expiresAtStr);
      final bool isValid = DateTime.now().isBefore(expiresAt);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 40,
              ),
              const SizedBox(width: 12),
              Text(
                isValid ? 'ACCESO CONCEDIDO' : 'ACCESO DENEGADO',
                style: TextStyle(
                  color: isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Espacio: $spaceName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Código: $accessCode'),
              Text(
                'Expira: ${expiresAt.toLocal().toString().substring(0, 16)}',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  isValid ? '¡Puede ingresar!' : 'Código expirado o inválido',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR No Válido'),
          content: const Text('Este código no pertenece a Cowork Mobile'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
