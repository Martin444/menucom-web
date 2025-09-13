import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
// Importar los nuevos controladores
import 'package:menu_dart_api/menu_com_api.dart';
import '../controllers/menu_controller.dart';
import '../controllers/filter_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

class MenuHomeBinding extends Bindings {
  @override
  void dependencies() {
    // === CONTROLADOR EXISTENTE (mantener para compatibilidad) ===
    Get.lazyPut(() => MenuHomeCartController());

    // ========================================
    // CONTROLADORES DE NUEVA ARQUITECTURA - ACTUALMENTE NO UTILIZADOS
    // ========================================
    // Los siguientes controladores implementan Clean Architecture pero no están
    // siendo utilizados en la UI actual. Solo se referencian en archivos de ejemplo comentados.
    //
    // ESTADO: Disponibles pero no activos en producción
    // RECOMENDACIÓN:
    // - Mantener para migración futura
    // - Comentar si quieres limpiar las dependencias
    // - Descomentar cuando implementes la migración de UI
    // ========================================

    // Use cases de menu_dart_api
    Get.lazyPut<GetMenuUseCase>(() => GetMenuUseCase());

    // Controladores especializados
    Get.lazyPut<MenuController>(
      () => MenuController(getMenuUseCase: Get.find<GetMenuUseCase>()),
    );

    Get.lazyPut<FilterController>(() => FilterController());

    Get.lazyPut<CartController>(() => CartController());

    // Controlador coordinador (nuevo)
    Get.lazyPut<HomeController>(
      () => HomeController(
        menuController: Get.find<MenuController>(),
        filterController: Get.find<FilterController>(),
        cartController: Get.find<CartController>(),
      ),
      tag: 'new', // Tag para diferenciarlo durante la migración
    );
  }
}
