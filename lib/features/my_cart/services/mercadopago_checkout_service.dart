import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MercadoPagoCheckoutService {
  static String extractPreferenceId(String value) {
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();

    final isUrl = lower.startsWith('http://') || lower.startsWith('https://');
    if (!isUrl) {
      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
      if (uuidRegex.hasMatch(value.trim())) return '';
      return value.trim();
    }

    try {
      final uri = Uri.parse(value);

      final qPref = uri.queryParameters['pref_id'] ?? uri.queryParameters['preference_id'];
      if (qPref != null && qPref.isNotEmpty) return qPref;

      final segments = uri.pathSegments;

      final prefIdx = segments.indexOf('preferences');
      if (prefIdx >= 0 && prefIdx + 1 < segments.length) {
        final id = segments[prefIdx + 1];
        if (id.isNotEmpty) return id;
      }

      if (segments.isNotEmpty && segments.last.contains('-') && segments.last.length > 10) {
        return segments.last;
      }
    } catch (e) {
      debugPrint('[PAY] extractPreferenceId: error parseando URL: $e');
    }

    return '';
  }

  static String? buildCheckoutUrl({
    required String preferenceId,
    String? redirectUrl,
  }) {
    if (preferenceId.isNotEmpty && !preferenceId.startsWith('TEST-')) {
      debugPrint('[PAY] Forzando URL de produccion con preferenceId');
      return 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
    }
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      debugPrint('[PAY] Usando redirectUrl original');
      return redirectUrl;
    }
    if (preferenceId.isNotEmpty) {
      debugPrint('[PAY] Usando preferenceId');
      return 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
    }
    return null;
  }

  static Future<bool> redirectToCheckout(String url) async {
    final uri = Uri.parse(url);
    debugPrint('[PAY] Abriendo URL de pago: $url');

    try {
      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_self');
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('[PAY] No se puede abrir la URL en este dispositivo');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[PAY] Error critico al abrir URL: $e');
      return false;
    }
  }
}
