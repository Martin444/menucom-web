import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// Importar los nuevos controladores
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_controller.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/filter_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('[CATALOG_BINDING] dependencies() called');

    // Use cases de menu_dart_api
    Get.lazyPut<GetCatalogByIdUseCase>(() => GetCatalogByIdUseCase());

    try {
      // Controladores especializados — put inmediato para que HomeController tenga dependencias listas
      Get.put<CatalogController>(
        CatalogController(getCatalogUseCase: Get.find<GetCatalogByIdUseCase>()),
      );
      debugPrint('[CATALOG_BINDING] CatalogController created');

      Get.put<FilterController>(FilterController());
      debugPrint('[CATALOG_BINDING] FilterController created');

      Get.put<CartController>(CartController());
      debugPrint('[CATALOG_BINDING] CartController created');

      // PWA Install controller
      Get.put<PwaInstallController>(PwaInstallController());
      debugPrint('[CATALOG_BINDING] PwaInstallController created');

      // Controlador coordinador — put inmediato para forzar onInit() en la entrada de ruta
      Get.put<HomeController>(
        HomeController(
          catalogController: Get.find<CatalogController>(),
          filterController: Get.find<FilterController>(),
          cartController: Get.find<CartController>(),
        ),
      );
      debugPrint('[CATALOG_BINDING] HomeController created');
    } catch (e, s) {
      debugPrint('[CATALOG_BINDING] ERROR creating controllers: $e\n$s');
    }
  }
}
