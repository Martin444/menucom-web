import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF Generator Service - Handles PDF generation for order receipts
class PdfGeneratorService {
  /// Generates a PDF receipt for the given order data
  static Future<void> generateOrderReceipt({
    required String orderId,
    required String status,
    required Map<String, String> paymentData,
    required String date,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Get status configuration
      final statusText = _getStatusText(status);
      final statusColor = _getStatusColorPdf(status);

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildPdfHeader(statusText, statusColor),
                pw.SizedBox(height: 30),

                // Order Information Section
                _buildPdfSection(
                  title: 'Información de la Orden',
                  items: [
                    _buildPdfDetailRow('ID de Orden:', orderId),
                    _buildPdfDetailRow('Fecha:', date),
                    _buildPdfDetailRow('Estado:', statusText),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Payment Details Section
                _buildPdfSection(
                  title: 'Detalles del Pago',
                  items: _buildPaymentDetailRows(paymentData),
                ),

                pw.Spacer(),

                // Footer
                _buildPdfFooter(),
              ],
            );
          },
        ),
      );

      // Generate PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // Download PDF
      _downloadPdf(pdfBytes, 'comprobante_$orderId.pdf');
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  /// Downloads the PDF file using web browser
  static void _downloadPdf(Uint8List pdfBytes, String filename) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)..setAttribute('download', filename);

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  /// Builds PDF header with title and status
  static pw.Widget _buildPdfHeader(String statusText, PdfColor statusColor) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [
            PdfColor.fromInt(0xFF667eea),
            PdfColor.fromInt(0xFF764ba2),
          ],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Comprobante de Pago',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Menucom - Sistema de Pedidos',
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: statusColor,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              statusText,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section with title and content
  static pw.Widget _buildPdfSection({
    required String title,
    required List<pw.Widget> items,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8F9FA),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left border indicator
          pw.Container(
            width: 4,
            height: 60,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF667eea),
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 16),
          // Content
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF2c3e50),
                  ),
                ),
                pw.SizedBox(height: 16),
                ...items,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a detail row for PDF
  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF495057),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                color: PdfColor.fromInt(0xFF6c757d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds payment detail rows
  static List<pw.Widget> _buildPaymentDetailRows(Map<String, String> paymentData) {
    final List<pw.Widget> rows = [];

    paymentData.forEach((key, value) {
      if (value.isNotEmpty) {
        rows.add(_buildPdfDetailRow(key, value));
      }
    });

    return rows;
  }

  /// Builds PDF footer
  static pw.Widget _buildPdfFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColor.fromInt(0xFFe9ecef),
            width: 1,
          ),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Este es un comprobante generado automáticamente por Menucom.',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromInt(0xFF6c757d),
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generado el ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromInt(0xFF6c757d),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Gets status text for display
  static String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return 'Pago Aprobado';
      case 'pending':
      case 'in_process':
        return 'Pago Pendiente';
      case 'rejected':
      case 'failure':
        return 'Pago Rechazado';
      default:
        return 'Estado: $status';
    }
  }

  /// Gets status color for PDF
  static PdfColor _getStatusColorPdf(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return const PdfColor.fromInt(0xFF4CAF50);
      case 'pending':
      case 'in_process':
        return const PdfColor.fromInt(0xFFFF9800);
      case 'rejected':
      case 'failure':
        return const PdfColor.fromInt(0xFFF44336);
      default:
        return const PdfColor.fromInt(0xFF757575);
    }
  }
}
