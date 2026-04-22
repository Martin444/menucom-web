import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class RequireLoginDialog extends StatelessWidget {
  final String commerceName;
  final VoidCallback onLogin;
  final VoidCallback onCancel;
  final bool isLoading;

  const RequireLoginDialog({
    super.key,
    required this.commerceName,
    required this.onLogin,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Casi listo para tu pedido',
              style: PuTextStyle.title1,
            ),
            const SizedBox(height: 16),
            Text(
              'Para completar tu compra en "$commerceName", inicia sesión con Google. Tu pedido se confirmará automáticamente al terminar.',
              style: PuTextStyle.description1,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ButtonPrimary(
                    title: 'Iniciar sesión con Google',
                    onPressed: isLoading ? () {} : onLogin,
                    load: isLoading,
                  ),
                  ButtonSecundary(
                    title: 'Cancelar orden',
                    onPressed: isLoading ? () {} : onCancel,
                    load: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
