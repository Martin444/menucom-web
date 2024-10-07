import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';

class MenuHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MenuHomeCartController());
  }
}
