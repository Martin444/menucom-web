import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui; // for platformViewRegistry on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // for DivElement container

import 'mercadopago_web.dart';

class MercadoPagoWalletBrick extends StatefulWidget {
  final String publicKey;
  final String preferenceId;
  final String locale;
  final String? containerId;
  final Map<String, dynamic>? options;

  const MercadoPagoWalletBrick({
    super.key,
    required this.publicKey,
    required this.preferenceId,
    this.locale = 'es-AR',
    this.containerId,
    this.options,
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

    if (kIsWeb) {
      _registerViewFactory();
      _initAndBuild();
    }
  }

  void _registerViewFactory() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final div = html.DivElement()
        ..id = _containerId
        ..style.width = '100%';
      return div;
    });
  }

  Future<void> _initAndBuild() async {
    try {
      if (!_initialized) {
        MercadoPagoWeb.init(publicKey: widget.publicKey, locale: widget.locale);
        _initialized = true;
      }
      await MercadoPagoWeb.checkout(
        preferenceId: widget.preferenceId,
        container: _containerId,
        options: widget.options,
      );
    } catch (e) {
      debugPrint('MercadoPago init/build error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
