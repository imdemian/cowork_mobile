import 'package:flutter/material.dart';

class DataProtectionPage extends StatelessWidget {
  const DataProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protección de Datos Personales')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AVISO DE PRIVACIDAD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Conforme a la Ley Federal de Protección de Datos Personales en Posesión de Particulares (LFPDPPP)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'RESPONSABLE DE LA PROTECCIÓN DE SUS DATOS PERSONALES',
              'CoWork Frontend, con domicilio en Ciudad de México, México, es responsable del uso y protección de sus datos personales, y al respecto le informamos lo siguiente:',
            ),

            _buildSection(
              'FINALIDADES DEL TRATAMIENTO DE DATOS',
              'Sus datos personales serán utilizados para las siguientes finalidades:\n\n'
                  'Finalidades Primarias (necesarias para el servicio):\n'
                  '• Creación y gestión de su cuenta de usuario\n'
                  '• Procesamiento de reservas de espacios de coworking\n'
                  '• Facturación y cobro de servicios\n'
                  '• Atención a solicitudes y servicio al cliente\n'
                  '• Cumplimiento de obligaciones legales\n\n'
                  'Finalidades Secundarias (mejoran su experiencia):\n'
                  '• Envío de comunicaciones promocionales\n'
                  '• Encuestas de satisfacción\n'
                  '• Mejora de nuestros servicios mediante análisis de uso\n'
                  '• Personalización de contenido y recomendaciones',
            ),

            _buildSection(
              'CONSENTIMIENTO INFORMADO',
              'Al registrarse en nuestra aplicación, usted acepta que:\n\n'
                  '• Ha leído y comprendido este aviso de privacidad\n'
                  '• Consiente el tratamiento de sus datos personales para las finalidades descritas\n'
                  '• Autoriza la recopilación y almacenamiento de su información\n'
                  '• Entiende sus derechos ARCO y cómo ejercerlos',
            ),

            _buildSection(
              'DATOS PERSONALES QUE RECABAMOS',
              'Para cumplir las finalidades descritas, solicitaremos los siguientes datos personales:\n\n'
                  'Datos de Identificación:\n'
                  '• Nombre completo\n'
                  '• Fecha de nacimiento\n'
                  '• Fotografía (opcional)\n\n'
                  'Datos de Contacto:\n'
                  '• Correo electrónico\n'
                  '• Número telefónico\n'
                  '• Dirección (opcional)\n\n'
                  'Datos Financieros:\n'
                  '• Información de tarjeta de crédito/débito (encriptada)\n'
                  '• RFC (para facturación)\n\n'
                  'Datos de Navegación:\n'
                  '• Dirección IP\n'
                  '• Cookies y tecnologías similares\n'
                  '• Datos de geolocalización (con su autorización)',
            ),

            _buildSection(
              'MEDIDAS DE SEGURIDAD',
              'Implementamos medidas de seguridad administrativas, técnicas y físicas para proteger sus datos personales:\n\n'
                  '• Cifrado de datos sensibles (SSL/TLS)\n'
                  '• Autenticación segura de usuarios\n'
                  '• Controles de acceso restringido\n'
                  '• Auditorías de seguridad periódicas\n'
                  '• Respaldos encriptados de información\n'
                  '• Políticas de confidencialidad para empleados',
            ),

            _buildSection(
              'DERECHOS ARCO',
              'Usted tiene derecho a:\n\n'
                  '📋 ACCEDER: Conocer qué datos personales tenemos y para qué los usamos\n\n'
                  '✏️ RECTIFICAR: Solicitar la corrección de datos inexactos o incompletos\n\n'
                  '🗑️ CANCELAR: Solicitar la eliminación de sus datos cuando considere que no están siendo utilizados adecuadamente\n\n'
                  '🚫 OPONERSE: Oponerse al tratamiento de sus datos para fines específicos\n\n'
                  'Para ejercer estos derechos, envíe su solicitud a:\n'
                  'Email: arco@cowork.com\n'
                  'Plazo de respuesta: 20 días hábiles',
            ),

            _buildSection(
              'REVOCACIÓN DEL CONSENTIMIENTO',
              'Puede revocar su consentimiento para el uso de sus datos personales en cualquier momento. Sin embargo, esto puede resultar en la imposibilidad de seguir prestándole nuestros servicios.\n\n'
                  'Para revocar su consentimiento, contacte a: revocacion@cowork.com',
            ),

            _buildSection(
              'TRANSFERENCIA DE DATOS',
              'Sus datos personales pueden ser compartidos con:\n\n'
                  '• Proveedores de servicios de pago (procesamiento seguro)\n'
                  '• Proveedores de hosting y almacenamiento en la nube\n'
                  '• Autoridades competentes cuando sea legalmente requerido\n\n'
                  'Todas las transferencias se realizan cumpliendo con la LFPDPPP y garantizando la protección de sus datos.',
            ),

            _buildSection(
              'USO DE COOKIES Y TECNOLOGÍAS SIMILARES',
              'Nuestra aplicación utiliza cookies y tecnologías similares para:\n\n'
                  '• Mantener su sesión activa\n'
                  '• Recordar sus preferencias\n'
                  '• Analizar el uso de la aplicación\n'
                  '• Mejorar la experiencia del usuario\n\n'
                  'Puede gestionar las cookies en la configuración de su dispositivo.',
            ),

            _buildSection(
              'NOTIFICACIÓN DE BRECHAS DE SEGURIDAD',
              'En caso de una brecha de seguridad que afecte sus datos personales:\n\n'
                  '• Le notificaremos dentro de las 72 horas siguientes\n'
                  '• Le informaremos sobre los datos afectados\n'
                  '• Le comunicaremos las medidas correctivas implementadas\n'
                  '• Le orientaremos sobre acciones que puede tomar',
            ),

            _buildSection(
              'RETENCIÓN DE DATOS',
              'Conservaremos sus datos personales durante:\n\n'
                  '• El tiempo que mantenga su cuenta activa\n'
                  '• Los períodos requeridos por obligaciones legales (5-10 años para datos fiscales)\n'
                  '• El tiempo necesario para resolver controversias\n\n'
                  'Después de estos períodos, sus datos serán eliminados de forma segura.',
            ),

            _buildSection(
              'CAMBIOS AL AVISO DE PRIVACIDAD',
              'Este aviso puede ser modificado para reflejar cambios en nuestras prácticas. Las modificaciones estarán disponibles en:\n\n'
                  '• Nuestra aplicación móvil\n'
                  '• Nuestro sitio web\n'
                  '• Por correo electrónico (cambios sustanciales)\n\n'
                  'Fecha de última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            ),

            _buildSection(
              'CONTACTO',
              'Para cualquier duda sobre este aviso o el tratamiento de sus datos personales:\n\n'
                  '📧 Email: privacidad@cowork.com\n'
                  '📞 Teléfono: +52 (55) 1234-5678\n'
                  '📍 Dirección: Ciudad de México, México\n'
                  '🕐 Horario de atención: Lunes a Viernes, 9:00 - 18:00 hrs',
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Información Importante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Al aceptar este aviso de privacidad, usted declara haber leído, '
                    'entendido y aceptado los términos aquí establecidos. Si no está '
                    'de acuerdo, le pedimos que no utilice nuestros servicios.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
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
