import 'package:flutter/widgets.dart';

class MercadoPagoWalletBrick extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // No-op on non-web platforms
    return const SizedBox.shrink();
  }
}
