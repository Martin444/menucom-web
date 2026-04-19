// Level: Page
// Description: Página coordinadora del carrito de compras. Conecta controladores con el Template.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/head_home.dart';
import 'package:menucom_catalog/features/my_cart/ui/templates/my_cart_template.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

class MyCartPage extends StatelessWidget {
  const MyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return MyCartTemplate(
      header: HeadHome(
        withBack: true,
        titleHead: 'Mi carrito',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      cartList: GetBuilder<HomeController>(
        builder: (controller) => CartItemList(
          items: controller.listMenuSelected,
          onAdd: (item) => controller.addquantityItem(item),
          onRemove: (item) => controller.removequantityItem(item),
        ),
      ),
      orderSummary: GetBuilder<HomeController>(
        builder: (controller) => CartOrderSummary(
          total: controller.totalOrder,
          onContinue: () {
            orderController.setOwnerId(controller.persistedOwnerId.value);
            orderController.createOrder(controller.listMenuSelected);
          },
        ),
      ),
    );
  }
}
