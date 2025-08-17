import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/services/pdf_generator_service.dart';

/// Download PDF Button Widget - Modular button for PDF generation
class DownloadPdfButton extends StatelessWidget {
  final String orderId;
  final String status;
  final Map<String, String> paymentData;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool isMobile;

  const DownloadPdfButton({
    Key? key,
    required this.orderId,
    required this.status,
    required this.paymentData,
    this.isLoading = false,
    this.onPressed,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _handleDownload,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.picture_as_pdf, size: 20),
        label: Text(
          isLoading ? 'Generando PDF...' : 'Descargar Comprobante PDF',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 16,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _handleDownload() {
    if (onPressed != null) {
      onPressed!();
    } else {
      _generatePdf();
    }
  }

  void _generatePdf() {
    // Show loading state
    Get.dialog(
      const _PdfGeneratingDialog(),
      barrierDismissible: false,
    );

    // Generate PDF using the service
    PdfGeneratorService.generateOrderReceipt(
      orderId: orderId,
      status: status,
      paymentData: paymentData,
      date: DateTime.now().toString().split('.')[0],
    ).then((_) {
      Get.back(); // Close loading dialog
      _showSuccessDialog();
    }).catchError((error) {
      Get.back(); // Close loading dialog
      _showErrorDialog(error.toString());
    });
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('PDF Generado'),
          ],
        ),
        content: Text(
          'El comprobante de la orden $orderId ha sido descargado exitosamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.error, color: Color(0xFFf44336)),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(
          'Error al generar el PDF: $error',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}

/// PDF Generating Dialog - Loading dialog for PDF generation
class _PdfGeneratingDialog extends StatelessWidget {
  const _PdfGeneratingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Generando PDF...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor espere mientras se genera su comprobante',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
