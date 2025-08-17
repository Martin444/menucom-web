import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/confirm_order_header.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/order_status_config.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/download_pdf_button.dart';
import 'package:pu_material/molecule/info_card.dart';

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

    // Map payment status to OrderStatus
    final orderStatus = OrderStatusConfig.mapPaymentStatusToOrderStatus(status);

    // Determine screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Create custom info items based on payment data
    final customInfoItems = <InfoItem>[
      InfoItem(label: 'ID de Orden:', value: merchantOrderId.isNotEmpty ? merchantOrderId : 'N/A'),
      if (paymentId.isNotEmpty) InfoItem(label: 'ID de Pago:', value: paymentId),
      if (collectionId.isNotEmpty) InfoItem(label: 'ID de Colección:', value: collectionId),
      InfoItem(label: 'Fecha:', value: _formatCurrentDate()),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              ConfirmOrderHeader(
                isMobile: isMobile,
                status: orderStatus,
                showStatusAnimation: true,
                customInfoItems: customInfoItems,
              ),
              Expanded(
                child: Container(
                  padding: isMobile
                      ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                      : EdgeInsets.symmetric(
                          horizontal: (MediaQuery.of(context).size.width - 600) / 2 > 20
                              ? (MediaQuery.of(context).size.width - 600) / 2
                              : 20,
                          vertical: 12,
                        ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildPaymentDetailsSection(
                          status: status,
                          paymentId: paymentId,
                          collectionId: collectionId,
                          paymentType: paymentType,
                          merchantOrderId: merchantOrderId,
                          preferenceId: preferenceId,
                          externalReference: externalReference,
                        ),
                        const SizedBox(height: 40),
                        _buildActionButtons(
                          status: status,
                          merchantOrderId: merchantOrderId,
                          paymentData: {
                            'Estado': status,
                            'ID de Pago': paymentId,
                            'ID de Colección': collectionId,
                            'Tipo de Pago': paymentType,
                            'ID de Preferencia': preferenceId,
                            'Referencia Externa': externalReference,
                          },
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMM yyyy, HH:mm', 'es_ES');
    return formatter.format(now);
  }

  Widget _buildPaymentDetailsSection({
    required String status,
    required String paymentId,
    required String collectionId,
    required String paymentType,
    required String merchantOrderId,
    required String preferenceId,
    required String externalReference,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Estado', status.isEmpty ? 'desconocido' : status),
          if (paymentType.isNotEmpty) _buildDetailRow('Tipo de Pago', paymentType),
          if (preferenceId.isNotEmpty) _buildDetailRow('ID de Preferencia', preferenceId),
          if (externalReference.isNotEmpty) _buildDetailRow('Referencia Externa', externalReference),
        ],
      ),
    );
  }

  Widget _buildActionButtons({
    required String status,
    required String merchantOrderId,
    required Map<String, String> paymentData,
    required bool isMobile,
  }) {
    return Column(
      children: [
        // PDF Download Button
        DownloadPdfButton(
          orderId: merchantOrderId.isNotEmpty ? merchantOrderId : 'N/A',
          status: status,
          paymentData: paymentData,
          isMobile: isMobile,
        ),
        const SizedBox(height: 16),
        
        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(PURoutes.HOME),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ir al inicio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.offAllNamed(PURoutes.MYCART),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667eea),
                  side: const BorderSide(color: Color(0xFF667eea)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ver carrito',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
