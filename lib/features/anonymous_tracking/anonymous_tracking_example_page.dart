import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/controllers/anonymous_tracking_controller.dart';

/// Página de ejemplo que demuestra el funcionamiento del
/// sistema de identificación anónima persistente
class AnonymousTrackingExamplePage extends StatelessWidget {
  const AnonymousTrackingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnonymousTrackingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous ID Tracking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ID Anónimo Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.anonymousId.isEmpty ? 'Generando...' : controller.anonymousId,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        )),
                    const SizedBox(height: 16),
                    const Text(
                      'Este ID se envía automáticamente en todas las peticiones HTTP como header X-Anonymous-Id',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.regenerateAnonymousId,
              child: const Text('Regenerar ID Anónimo'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.clearAnonymousId,
              child: const Text('Limpiar ID Almacenado'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => controller.sendOrderExample({
                'items': [
                  {'id': 1, 'name': 'Producto de prueba', 'price': 10.99}
                ],
                'total': 10.99,
              }),
              child: const Text('Enviar Orden de Prueba'),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Características del Sistema:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Almacenamiento persistente (SharedPreferences/localStorage)'),
                    Text('• Generación automática de UUID v4'),
                    Text('• Header automático X-Anonymous-Id en todas las requests'),
                    Text('• Compatibilidad móvil y web'),
                    Text('• Fallback en caso de errores'),
                    Text('• Logging solo en modo debug'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'El ID anónimo permite al backend vincular órdenes\nsin requerir autenticación del usuario.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
