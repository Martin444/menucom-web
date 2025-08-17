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
    final externalReference = params['external_reference'] ?? '';
    final collectionId = params['collection_id'] ?? '';
    final paymentType = params['payment_type'] ?? '';

    // Determinar el estado del pago
    final isApproved = status == 'approved' || status == 'success';
    final isPending = status == 'pending' || status == 'in_process';
    final isRejected = status == 'rejected' || status == 'failure';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del pago'),
        backgroundColor: isApproved
            ? Colors.green
            : isPending
                ? Colors.orange
                : isRejected
                    ? Colors.red
                    : Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado visual del pago
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isApproved
                    ? Colors.green.shade50
                    : isPending
                        ? Colors.orange.shade50
                        : isRejected
                            ? Colors.red.shade50
                            : Colors.grey.shade50,
                border: Border.all(
                  color: isApproved
                      ? Colors.green
                      : isPending
                          ? Colors.orange
                          : isRejected
                              ? Colors.red
                              : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isApproved
                            ? Icons.check_circle
                            : isPending
                                ? Icons.schedule
                                : isRejected
                                    ? Icons.error
                                    : Icons.help,
                        color: isApproved
                            ? Colors.green
                            : isPending
                                ? Colors.orange
                                : isRejected
                                    ? Colors.red
                                    : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isApproved
                            ? 'Pago Aprobado'
                            : isPending
                                ? 'Pago Pendiente'
                                : isRejected
                                    ? 'Pago Rechazado'
                                    : 'Estado Desconocido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isApproved
                              ? Colors.green
                              : isPending
                                  ? Colors.orange
                                  : isRejected
                                      ? Colors.red
                                      : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isApproved
                        ? 'Tu pago se procesó correctamente'
                        : isPending
                            ? 'Tu pago está siendo procesado'
                            : isRejected
                                ? 'Hubo un problema con tu pago'
                                : 'Estado del pago desconocido',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detalles del pago
            const Text('Detalles del pago:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow('Estado', status.isEmpty ? 'desconocido' : status),
            if (paymentId.isNotEmpty) _buildDetailRow('ID de Pago', paymentId),
            if (collectionId.isNotEmpty) _buildDetailRow('ID de Colección', collectionId),
            if (paymentType.isNotEmpty) _buildDetailRow('Tipo de Pago', paymentType),
            if (merchantOrderId.isNotEmpty) _buildDetailRow('ID de Orden', merchantOrderId),
            if (preferenceId.isNotEmpty) _buildDetailRow('ID de Preferencia', preferenceId),
            if (externalReference.isNotEmpty) _buildDetailRow('Referencia Externa', externalReference),

            const Spacer(),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(PURoutes.HOME),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ir al inicio'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(PURoutes.MYCART),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ver carrito'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
