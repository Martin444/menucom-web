import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
      // For now, we'll generate a simple HTML-based PDF
      // In a real implementation, you might use packages like pdf or printing
      final htmlContent = _generateHtmlContent(
        orderId: orderId,
        status: status,
        paymentData: paymentData,
        date: date,
      );

      // Create a blob and download it
      final bytes = Uint8List.fromList(htmlContent.codeUnits);
      final blob = html.Blob([bytes], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create download link
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'comprobante_$orderId.html');
      
      // Add to document and trigger download
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  /// Generates HTML content for the receipt
  static String _generateHtmlContent({
    required String orderId,
    required String status,
    required Map<String, String> paymentData,
    required String date,
  }) {
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Comprobante de Pago - $orderId</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
            color: #333;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: bold;
        }
        .header p {
            margin: 5px 0 0 0;
            opacity: 0.9;
        }
        .status-badge {
            display: inline-block;
            padding: 8px 16px;
            background-color: $statusColor;
            color: white;
            border-radius: 20px;
            font-weight: bold;
            margin: 15px 0;
        }
        .details-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }
        .details-section h2 {
            margin-top: 0;
            color: #2c3e50;
            font-size: 20px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e9ecef;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 600;
            color: #495057;
            flex: 1;
        }
        .detail-value {
            flex: 2;
            text-align: right;
            color: #6c757d;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            border-top: 1px solid #e9ecef;
            color: #6c757d;
            font-size: 14px;
        }
        @media print {
            body {
                margin: 0;
                padding: 15px;
            }
            .header {
                background: #667eea !important;
                -webkit-print-color-adjust: exact;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Comprobante de Pago</h1>
        <p>Menucom - Sistema de Pedidos</p>
        <div class="status-badge">$statusText</div>
    </div>

    <div class="details-section">
        <h2>Información de la Orden</h2>
        <div class="detail-row">
            <span class="detail-label">ID de Orden:</span>
            <span class="detail-value">$orderId</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Fecha:</span>
            <span class="detail-value">$date</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Estado:</span>
            <span class="detail-value">$statusText</span>
        </div>
    </div>

    <div class="details-section">
        <h2>Detalles del Pago</h2>
        ${_generatePaymentDetailsHtml(paymentData)}
    </div>

    <div class="footer">
        <p>Este es un comprobante generado automáticamente por Menucom.</p>
        <p>Generado el ${DateTime.now().toString().split('.')[0]}</p>
    </div>
</body>
</html>
    ''';
  }

  static String _generatePaymentDetailsHtml(Map<String, String> paymentData) {
    final buffer = StringBuffer();
    
    paymentData.forEach((key, value) {
      if (value.isNotEmpty) {
        buffer.write('''
        <div class="detail-row">
            <span class="detail-label">$key:</span>
            <span class="detail-value">$value</span>
        </div>
        ''');
      }
    });

    return buffer.toString();
  }

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

  static String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return '#4CAF50';
      case 'pending':
      case 'in_process':
        return '#FF9800';
      case 'rejected':
      case 'failure':
        return '#F44336';
      default:
        return '#757575';
    }
  }
}
