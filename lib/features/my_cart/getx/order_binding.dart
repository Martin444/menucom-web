import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderController());
  }
}
