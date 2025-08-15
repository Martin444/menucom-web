import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/order_status_config.dart';

/// Confirm Order Actions Widget
class ConfirmOrderActions extends StatelessWidget {
  final bool isMobile;
  final GlobalKey<FormState> formKey;
  final TextEditingController contactController;
  final OrderController orderController;

  const ConfirmOrderActions({
    Key? key,
    required this.isMobile,
    required this.formKey,
    required this.contactController,
    required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isConfirmed = orderController.orderStatus.value == OrderStatus.confirmed;
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFf8f9fa),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ButtonPrimary(
            onPressed: () {
              if (isConfirmed) {
                // Acción para seguir comprando, por ejemplo, navegar a la tienda principal
                Get.back();
              } else {
                if (formKey.currentState?.validate() ?? false) {
                  orderController.saveContactToLastOrder(contactController.text);
                }
              }
            },
            load: orderController.isOrderLoading.value,
            title: isConfirmed ? 'Seguir comprando' : 'Confirmar',
          ),
        ),
      );
    });
  }
}
