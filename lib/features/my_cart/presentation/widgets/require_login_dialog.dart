import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Diálogo atómico para requerir login en Menucom
class RequireLoginDialog extends StatelessWidget {
  final String commerceName;
  final VoidCallback onLogin;
  final VoidCallback onCancel;

  const RequireLoginDialog({
    super.key,
    required this.commerceName,
    required this.onLogin,
    required this.onCancel,
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
              'Iniciar sesión requerido',
              style: PuTextStyle.title1,
            ),
            const SizedBox(height: 16),
            Text(
              'Para seguir comprando en "$commerceName" tienes que iniciar sesión con Menucom.',
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
                    title: 'Iniciar sesión',
                    onPressed: onLogin,
                    load: false,
                  ),
                  ButtonSecundary(
                    title: 'Cancelar orden',
                    onPressed: onCancel,
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
