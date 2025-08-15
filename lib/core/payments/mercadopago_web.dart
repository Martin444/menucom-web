// Lightweight web wrapper for MercadoPago.js V2 using js-interop
// Only used on web; guard imports where used.

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class MercadoPagoWeb {
  /// Initialize SDK with your public key and optional locale (e.g., 'es-AR')
  static void init({required String publicKey, String locale = 'es-AR'}) {
    js.context.callMethod('mpInit', [publicKey, locale]);
  }

  /// Create Wallet Brick (checkout)
  /// container: DOM element id where the widget will be created
  static Future<bool> checkout({
    required String preferenceId,
    String container = 'mp-checkout-container',
    Map<String, dynamic>? options,
  }) async {
    final cfg = {
      'container': container,
      if (options != null) ...options,
    };
    final result = await js.context.callMethod('mpCheckout', [preferenceId, cfg]);
    return result == true;
  }

  /// Advanced: create card form (returns only success boolean via bridge)
  static bool createCardForm(Map<String, dynamic> options) {
    final result = js.context.callMethod('mpCreateCardForm', [options]);
    return result == true;
  }
}
