import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/routes/routes.dart';

class CheckoutStatusPage extends StatelessWidget {
  const CheckoutStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Support both Flutter Web (Get.parameters) and direct ModalRoute query parsing
    final params = Get.parameters; // works for /#/route?query=...
    final preferenceId = params['preference_id'] ?? params['preferenceId'] ?? '';
    final merchantOrderId = params['merchant_order_id'] ?? params['merchantOrderId'] ?? '';
    final status = params['status'] ?? params['collection_status'] ?? '';
    final paymentId = params['payment_id'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${status.isEmpty ? 'desconocido' : status}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('preference_id: ${preferenceId.isEmpty ? '-' : preferenceId}'),
            const SizedBox(height: 4),
            Text('merchant_order_id: ${merchantOrderId.isEmpty ? '-' : merchantOrderId}'),
            const SizedBox(height: 4),
            Text('payment_id: ${paymentId.isEmpty ? '-' : paymentId}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(PURoutes.HOME),
                  child: const Text('Ir al inicio'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(PURoutes.CONFIRMORDER),
                  child: const Text('Volver a la orden'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
