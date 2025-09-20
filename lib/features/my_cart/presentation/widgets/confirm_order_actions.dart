// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/order_status_config.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/require_login_dialog.dart';

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
    return Obx(
      () {
        final isConfirmed = orderController.orderStatus.value == OrderStatus.confirmed;
        // Obtener nombre del comercio desde el controller global
        final menuController = Get.find<MenuHomeCartController>();
        String commerceName = '';
        if (menuController.ownerInfo.value?.name != null && menuController.ownerInfo.value!.name!.isNotEmpty) {
          commerceName = menuController.ownerInfo.value!.name!;
        } else if (menuController.nameComerce.value.isNotEmpty) {
          commerceName = menuController.nameComerce.value;
        } else {
          commerceName = 'Comercio';
        }
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf8f9fa),
          ),
          child: Center(
            child: SizedBox(
              width: 300,
              child: ButtonPrimary(
                onPressed: () {
                  if (isConfirmed) {
                    Get.back();
                  } else {
                    // Interceptar si no hay token
                    if (ACCESS_TOKEN.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (ctx) => RequireLoginDialog(
                          commerceName: commerceName,
                          onLogin: () async {
                            Navigator.of(ctx).pop();
                            html.window.location.href = 'https://menucom-dashboard.netlify.app/';
                          },
                          onCancel: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      );
                      return;
                    }
                    if (formKey.currentState?.validate() ?? false) {
                      orderController.saveContactToLastOrder(contactController.text);
                    }
                  }
                },
                load: orderController.isOrderLoading.value,
                title: isConfirmed ? 'Seguir comprando' : 'Confirmar',
              ),
            ),
          ),
        );
      },
    );
  }
}
