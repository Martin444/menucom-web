import 'package:get/get.dart';

import '../features/home/presentation/getx/menu_home_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MenuHomeCartController(),
      fenix: true,
    );
  }
}
