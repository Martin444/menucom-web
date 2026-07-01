import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/order_status_config.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/core/services/google_auth_service.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/require_login_dialog.dart';

class ConfirmOrderActions extends StatefulWidget {
  final bool isMobile;
  final OrderController orderController;

  const ConfirmOrderActions({
    super.key,
    required this.isMobile,
    required this.orderController,
  });

  @override
  State<ConfirmOrderActions> createState() => _ConfirmOrderActionsState();
}

class _ConfirmOrderActionsState extends State<ConfirmOrderActions> {
  bool _isLoggingIn = false;

  Future<void> _handleGoogleLogin(BuildContext context) async {
    setState(() => _isLoggingIn = true);

    final success = await widget.orderController.loginAndConfirmOrder();

    if (!mounted) return;

    if (context.mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Sesión iniciada! Procesando tu orden...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isConfirmed = widget.orderController.orderStatus.value == OrderStatus.confirmed;
        final homeController = Get.find<HomeController>();
        final commerceName = homeController.nameComerce.isNotEmpty 
            ? homeController.nameComerce 
            : 'Comercio';
            
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf8f9fa),
          ),
          child: Center(
            child: SizedBox(
              width: 300,
              child: ButtonPrimary(
                onPressed: () async {
                  if (isConfirmed) {
                    Get.back();
                  } else {
                    if (ACCESS_TOKEN.isEmpty) {
                      // Intentar login silencioso primero (por si hubo reload o ya está en Firebase)
                      setState(() => _isLoggingIn = true);
                      try {
                        await GoogleAuthService().signInSilently();
                      } finally {
                        if (mounted) setState(() => _isLoggingIn = false);
                      }
                      
                      if (ACCESS_TOKEN.isNotEmpty) {
                        widget.orderController.saveContactToLastOrder(NAME_USER);
                        return;
                      }

                      if (!context.mounted) return;

                      showDialog(
                        context: context,
                        builder: (ctx) => RequireLoginDialog(
                          commerceName: commerceName,
                          isLoading: _isLoggingIn,
                          onLogin: () async {
                            await _handleGoogleLogin(ctx);
                          },
                          onCancel: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      );
                      return;
                    }
                    // No validamos formulario porque el nombre viene del login
                    widget.orderController.saveContactToLastOrder(NAME_USER);
                  }
                },
                load: widget.orderController.isOrderLoading.value || _isLoggingIn,
                title: isConfirmed ? 'Seguir comprando' : 'Confirmar',
              ),
            ),
          ),
        );
      },
    );
  }
}
