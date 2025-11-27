import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'POLÍTICA DE PRIVACIDAD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. INFORMACIÓN GENERAL',
              'CoWork Frontend, en adelante "la Aplicación", respeta su privacidad y se compromete a proteger sus datos personales. Esta política de privacidad le informará sobre cómo cuidamos sus datos personales cuando utiliza nuestra aplicación móvil.',
            ),

            _buildSection(
              '2. DATOS QUE RECOPILAMOS',
              'Podemos recopilar, usar, almacenar y transferir diferentes tipos de datos personales sobre usted:\n\n'
                  '• Datos de identidad: nombre, apellido, nombre de usuario\n'
                  '• Datos de contacto: dirección de correo electrónico, número de teléfono\n'
                  '• Datos de la cuenta: nombre de usuario, contraseña\n'
                  '• Datos de uso: información sobre cómo utiliza nuestra aplicación\n'
                  '• Datos técnicos: dirección IP, tipo de navegador, zona horaria',
            ),

            _buildSection(
              '3. CÓMO USAMOS SUS DATOS',
              'Utilizamos sus datos personales para:\n\n'
                  '• Proporcionarle acceso a nuestros servicios de coworking\n'
                  '• Gestionar su cuenta y reservas\n'
                  '• Mejorar nuestra aplicación y servicios\n'
                  '• Enviarle comunicaciones relacionadas con el servicio\n'
                  '• Cumplir con obligaciones legales',
            ),

            _buildSection(
              '4. SEGURIDAD DE DATOS',
              'Hemos implementado medidas de seguridad apropiadas para prevenir que sus datos personales sean accidentalmente perdidos, usados o accedidos de manera no autorizada. Limitamos el acceso a sus datos personales a aquellos empleados y colaboradores que tienen una necesidad comercial de conocerlos.',
            ),

            _buildSection(
              '5. COMPARTIR SUS DATOS',
              'No vendemos ni alquilamos su información personal a terceros. Podemos compartir sus datos con:\n\n'
                  '• Proveedores de servicios que nos ayudan a operar nuestra aplicación\n'
                  '• Autoridades gubernamentales cuando sea legalmente requerido\n'
                  '• Socios comerciales con su consentimiento explícito',
            ),

            _buildSection(
              '6. SUS DERECHOS LEGALES (ARCO)',
              'Bajo la Ley Federal de Protección de Datos Personales en Posesión de Particulares (LFPDPPP), usted tiene derecho a:\n\n'
                  '• Acceder: conocer qué datos personales tenemos sobre usted\n'
                  '• Rectificar: corregir sus datos si son inexactos\n'
                  '• Cancelar: solicitar la eliminación de sus datos\n'
                  '• Oponerse: oponerse al procesamiento de sus datos\n\n'
                  'Para ejercer estos derechos, contacte a: privacidad@cowork.com',
            ),

            _buildSection(
              '7. RETENCIÓN DE DATOS',
              'Conservaremos sus datos personales solo durante el tiempo necesario para cumplir con los propósitos para los que fueron recopilados, incluidos los requisitos legales, contables o de informes.',
            ),

            _buildSection(
              '8. TRANSFERENCIAS INTERNACIONALES',
              'Sus datos pueden ser transferidos y mantenidos en servidores ubicados fuera de México. Nos aseguraremos de que cualquier transferencia cumpla con las leyes aplicables de protección de datos.',
            ),

            _buildSection(
              '9. CAMBIOS A ESTA POLÍTICA',
              'Podemos actualizar esta política de privacidad periódicamente. Le notificaremos sobre cualquier cambio publicando la nueva política en esta página y actualizando la fecha de "última actualización".',
            ),

            _buildSection(
              '10. CONTACTO',
              'Si tiene preguntas sobre esta política de privacidad o nuestras prácticas de privacidad, contáctenos en:\n\n'
                  'Email: privacidad@cowork.com\n'
                  'Teléfono: +52 (55) 1234-5678\n'
                  'Dirección: Ciudad de México, México',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
