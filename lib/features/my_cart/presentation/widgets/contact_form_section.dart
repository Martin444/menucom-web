import 'package:flutter/material.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';
import 'package:pu_material/pu_material.dart';

/// Contact Form Section Widget
class ContactFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController contactController;
  final OrderController orderController;

  const ContactFormSection({
    Key? key,
    required this.formKey,
    required this.contactController,
    required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          PUInput(
            controller: contactController,
            hintText: 'Ingresa tu número de teléfono o email',
            errorText: orderController.errorText.value.isNotEmpty 
                ? orderController.errorText.value 
                : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu número de teléfono o email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Para confirmar tu pedido, necesitamos un contacto para que el vendedor coordine la entrega de tu compra.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}