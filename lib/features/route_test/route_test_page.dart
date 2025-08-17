import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/routes/routes.dart';

/// Página de prueba para verificar las rutas de checkout
class RouteTestPage extends StatelessWidget {
  const RouteTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Rutas de Checkout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Probar diferentes estados de checkout:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Pago Aprobado
            ElevatedButton(
              onPressed: () => _navigateToCheckout('approved'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Pago Aprobado (approved)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),

            // Pago Pendiente
            ElevatedButton(
              onPressed: () => _navigateToCheckout('pending'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Pago Pendiente (pending)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),

            // Pago Rechazado
            ElevatedButton(
              onPressed: () => _navigateToCheckout('rejected'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Pago Rechazado (rejected)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),

            // Estado Desconocido
            ElevatedButton(
              onPressed: () => _navigateToCheckout('unknown'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Estado Desconocido', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),

            // Simulación completa de MercadoPago
            ElevatedButton(
              onPressed: _simulateMercadoPagoResponse,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Simular respuesta completa de MercadoPago', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ruta configurada:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('/checkout/status'),
                    SizedBox(height: 12),
                    Text(
                      'URL de prueba compatible con:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('https://menu-comerce.netlify.app/#/checkout/status?status=success&...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCheckout(String status) {
    final params = {
      'status': status,
      'collection_status': status,
      'payment_id': '1340493953',
      'collection_id': '1340493953',
      'external_reference': '9f36aec2-3366-4f09-844d-8e91b6f3aaba',
      'payment_type': 'debit_card',
      'merchant_order_id': '33252270327',
      'preference_id': '367500631-bac1bc27-540a-498c-a9e2-6df28896d98e',
      'site_id': 'MLA',
      'processing_mode': 'aggregator',
    };

    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

    Get.toNamed('${PURoutes.CHECKOUT_STATUS}?$queryString');
  }

  void _simulateMercadoPagoResponse() {
    // Simula la URL exacta que proporcionaste
    const url =
        '/checkout/status?status=success&status=approved&collection_id=1340493953&collection_status=approved&payment_id=1340493953&external_reference=9f36aec2-3366-4f09-844d-8e91b6f3aaba&payment_type=debit_card&merchant_order_id=33252270327&preference_id=367500631-bac1bc27-540a-498c-a9e2-6df28896d98e&site_id=MLA&processing_mode=aggregator&merchant_account_id=null';

    Get.toNamed(url);
  }
}
