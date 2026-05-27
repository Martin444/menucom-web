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
    // === NUEVA ARQUITECTURA DE CONTROLADORES ===

    // Use cases de menu_dart_api
    Get.lazyPut<GetCatalogByIdUseCase>(() => GetCatalogByIdUseCase());

    // Controladores especializados
    Get.lazyPut<CatalogController>(
      () => CatalogController(getCatalogUseCase: Get.find<GetCatalogByIdUseCase>()),
    );

    Get.lazyPut<FilterController>(() => FilterController());

    Get.lazyPut<CartController>(() => CartController());

    // PWA Install controller
    Get.lazyPut<PwaInstallController>(() => PwaInstallController());

    // Controlador coordinador (Reemplaza a MenuHomeCartController)
    Get.lazyPut<HomeController>(
      () => HomeController(
        catalogController: Get.find<CatalogController>(),
        filterController: Get.find<FilterController>(),
        cartController: Get.find<CartController>(),
      ),
    );
  }
}
