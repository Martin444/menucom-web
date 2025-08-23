import 'package:flutter/material.dart';

// Use platformViewRegistry from dart:ui_web (deprecated in dart:ui)
import 'dart:ui_web' as ui; // for platformViewRegistry on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // for DivElement container

import 'mercadopago_web.dart';

class MercadoPagoWalletBrick extends StatefulWidget {
  final String publicKey;
  final String preferenceId;
  final String locale;
  final String? containerId;
  final Map<String, dynamic>? options;
  final double height;

  const MercadoPagoWalletBrick({
    super.key,
    required this.publicKey,
    required this.preferenceId,
    this.locale = 'es-AR',
    this.containerId,
    this.options,
    this.height = 460,
  });

  @override
  State<MercadoPagoWalletBrick> createState() => _MercadoPagoWalletBrickState();
}

class _MercadoPagoWalletBrickState extends State<MercadoPagoWalletBrick> {
  late final String _containerId;
  late final String _viewType;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _containerId = widget.containerId ?? 'mp-checkout-${DateTime.now().millisecondsSinceEpoch}';
    _viewType = 'mp-wallet-brick-$_containerId';
    _registerViewFactory();
    // Ejecutar luego del primer frame para asegurar que el HtmlElementView esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndBuild();
    });
  }

  void _registerViewFactory() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      debugPrint('[MP_WIDGET] Register view factory for $_viewType with container: $_containerId');
      final div = html.DivElement()
        ..id = _containerId
        ..style.width = '100%'
        ..style.height = '${widget.height}px';
      debugPrint('[MP_WIDGET] Created div with id=$_containerId');
      return div;
    });
  }

  Future<void> _initAndBuild() async {
    try {
      // Validar configuración antes de inicializar
      if (widget.publicKey.isEmpty || widget.publicKey == 'undefined') {
        throw Exception('MercadoPago public key is not configured');
      }

      if (widget.preferenceId.isEmpty || widget.preferenceId == 'undefined') {
        throw Exception('MercadoPago preference ID is empty or invalid');
      }

      debugPrint(
          '[MP_WIDGET] Validaciones pasadas - publicKey: ${widget.publicKey.substring(0, 8)}..., preferenceId: ${widget.preferenceId}');

      if (!_initialized) {
        MercadoPagoWeb.init(publicKey: widget.publicKey, locale: widget.locale);
        _initialized = true;
      }
      // Esperar a que el contenedor exista en el DOM
      final ok = await _waitForContainer();
      if (!ok) {
        debugPrint('MercadoPago container not found: $_containerId');
        return;
      }
      debugPrint('[MP_WIDGET] Container $_containerId found. Calling checkout...');
      debugPrint('[MP_WIDGET] PreferenceId: ${widget.preferenceId}');

      final result = await MercadoPagoWeb.checkout(
        preferenceId: widget.preferenceId,
        container: _containerId,
        options: {
          'container': _containerId, // Keep for compatibility when using mpCheckout (not used in mpCheckout2)
          if (widget.options != null) ...widget.options!,
        },
      );

      if (result) {
        debugPrint('[MP_WIDGET] Checkout invoked successfully');
      } else {
        debugPrint('[MP_WIDGET] Checkout failed');
      }
    } catch (e) {
      debugPrint('MercadoPago init/build error: $e');
      // Show error in container
      _showErrorInContainer(e.toString());
    }
  }

  void _showErrorInContainer(String error) {
    // This would need to be implemented with a proper error widget
    debugPrint('[MP_WIDGET] Error to show: $error');
  }

  Future<bool> _waitForContainer({int attempts = 20, Duration delay = const Duration(milliseconds: 50)}) async {
    for (int i = 0; i < attempts; i++) {
      final el = html.document.getElementById(_containerId);
      if (el != null) {
        debugPrint('[MP_WIDGET] _waitForContainer success at attempt $i');
        return true;
      }
      await Future.delayed(delay);
    }
    debugPrint('[MP_WIDGET] _waitForContainer timeout for $_containerId');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
