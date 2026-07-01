import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/ui/organisms/head_home_organism.dart';
import 'package:menucom_catalog/features/my_cart/ui/templates/my_cart_template.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

class MyCartPage extends StatelessWidget {
  const MyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    final homeCtrl = Get.find<HomeController>();
    orderController.onPaymentCompleted = () => Get.find<CartController>().clearCart();

    return MyCartTemplate(
      header: HeadHomeOrganism(
        withBack: true,
        titleHead: 'Mi carrito',
        onBack: () => Navigator.of(context).maybePop(),
        commerceName: '',
      ),
      cartList: GetBuilder<CartController>(
        builder: (cartCtrl) => CartItemList(
          items: cartCtrl.cartItems,
          onAdd: (item) => homeCtrl.addquantityItem(item),
          onRemove: (item) => homeCtrl.removequantityItem(item),
        ),
      ),
      orderSummary: GetBuilder<CartController>(
        builder: (cartCtrl) => CartOrderSummary(
          total: cartCtrl.total,
          onContinue: () {
            orderController.setCommerceId(homeCtrl.commerceId.value);
            orderController.createOrder(cartCtrl.cartItems);
          },
        ),
      ),
    );
  }
}
