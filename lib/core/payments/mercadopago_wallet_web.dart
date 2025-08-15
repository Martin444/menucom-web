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
      await MercadoPagoWeb.checkout(
        preferenceId: widget.preferenceId,
        container: _containerId,
        options: {
          'container': _containerId, // Keep for compatibility when using mpCheckout (not used in mpCheckout2)
          if (widget.options != null) ...widget.options!,
        },
      );
      debugPrint('[MP_WIDGET] Checkout invoked');
    } catch (e) {
      debugPrint('MercadoPago init/build error: $e');
    }
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
