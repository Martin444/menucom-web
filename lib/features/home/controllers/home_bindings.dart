// ========================================
// ARCHIVO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN O MIGRACIÓN
// ========================================
// Este archivo contiene bindings alternativos para la nueva arquitectura Clean Architecture.
// Sin embargo, la aplicación actualmente usa menu_binding.dart en la carpeta getx/
// que mantiene compatibilidad entre la arquitectura nueva y legacy.
// 
// ESTADO ACTUAL:
// - No hay referencias a HomeBindings en ningún archivo
// - Los bindings activos están en getx/menu_binding.dart
// - Este archivo fue creado como parte del refactoring pero no se implementó
// 
// RECOMENDACIONES:
// 1. Si quieres usar la nueva arquitectura completamente, reemplaza menu_binding.dart con este
// 2. Si mantienes la migración gradual, puedes eliminar este archivo
// 3. Considera mantenerlo como referencia para migración futura
// ========================================

/*
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'menu_controller.dart';
import 'filter_controller.dart';
import 'cart_controller.dart';
import 'home_controller.dart';

/// Bindings para los controladores especializados del home
/// Implementa la inyección de dependencias siguiendo Clean Architecture
class HomeBindings implements Bindings {
  @override
  void dependencies() {
    // === REGISTRAR USE CASES DE MENU_DART_API ===

    // GetMenuUseCase - para cargar menús
    Get.lazyPut<GetMenuUseCase>(
      () => GetMenuUseCase(),
    );

    // === REGISTRAR CONTROLADORES ESPECIALIZADOS ===

    // MenuController - gestión de datos del menú
    Get.lazyPut<MenuController>(
      () => MenuController(
        getMenuUseCase: Get.find<GetMenuUseCase>(),
      ),
    );

    // FilterController - gestión de filtros y búsquedas
    Get.lazyPut<FilterController>(
      () => FilterController(),
    );

    // CartController - gestión del carrito
    Get.lazyPut<CartController>(
      () => CartController(),
    );

    // === REGISTRAR CONTROLADOR COORDINADOR ===

    // HomeController - coordinador principal
    Get.lazyPut<HomeController>(
      () => HomeController(
        menuController: Get.find<MenuController>(),
        filterController: Get.find<FilterController>(),
        cartController: Get.find<CartController>(),
      ),
    );

    // === COMPATIBILIDAD CON CONTROLADOR EXISTENTE ===

    // Alias para compatibilidad gradual con la UI existente
    // Permite usar Get.find<MenuHomeCartController>() mientras se migra
    Get.lazyPut<MenuHomeCartController>(
      () => _HomeControllerAdapter(Get.find<HomeController>()),
      tag: 'legacy',
    );
  }
}

/// Adaptador para mantener compatibilidad con el controlador existente
/// Permite migración gradual de la UI sin romper funcionalidad existente
class _HomeControllerAdapter extends GetxController implements MenuHomeCartController {
  final HomeController _homeController;

  _HomeControllerAdapter(this._homeController);

  // === PROPIEDADES PÚBLICAS (compatibilidad) ===

  @override
  RxList<MenuModel> get listMenu => _homeController.listMenu?.obs ?? <MenuModel>[].obs;

  @override
  RxList<MenuItemModel> get listMenuItems => _homeController.listMenuItems.obs;

  @override
  RxBool get isLoadHomeItems => _homeController.isLoadHomeItems.obs;

  @override
  RxString get errorText => _homeController.errorText.obs;

  @override
  RxString get nameComerce => _homeController.nameComerce.obs;

  @override
  Rx<OwnerModel?> get ownerInfo => Rx<OwnerModel?>(_homeController.ownerInfo);

  @override
  RxString get persistedOwnerId => _homeController.currentOwnerId.obs;

  @override
  RxString get searchQuery => _homeController.searchQuery.obs;

  @override
  RxString get selectedCategory => _homeController.selectedCategory.obs;

  @override
  RxList<String> get availableCategories => _homeController.availableCategories.obs;

  @override
  RxBool get isGridView => _homeController.isGridView.obs;

  @override
  RxString get sortBy => _homeController.sortBy.obs;

  @override
  RxList<MenuModel> get filteredMenu => (_homeController.listMenu ?? []).obs;

  @override
  RxList<MenuItemModel> get filteredMenuItems => _homeController.filteredMenuItems.obs;

  // === MÉTODOS PÚBLICOS (compatibilidad) ===

  @override
  String get currentOwnerId => _homeController.currentOwnerId;

  @override
  void clearPersistedOwnerId() => _homeController.clearPersistedOwnerId();

  @override
  void updateSearchQuery(String query) => _homeController.updateSearchQuery(query);

  @override
  void selectCategory(String category) => _homeController.selectCategory(category);

  @override
  void clearFilters() => _homeController.clearFilters();

  @override
  void setSortBy(String sortOption) => _homeController.setSortBy(sortOption);

  @override
  void toggleViewMode() => _homeController.toggleViewMode();

  // Métodos específicos del controlador original que necesiten implementación específica
  // Se pueden delegar al HomeController o implementar de forma compatible
}

/// Interface para el controlador original (para compatibilidad)
/// Define el contrato que debe cumplir el adaptador
abstract class MenuHomeCartController extends GetxController {
  // Propiedades observables
  RxList<MenuModel> get listMenu;
  RxList<MenuItemModel> get listMenuItems;
  RxBool get isLoadHomeItems;
  RxString get errorText;
  RxString get nameComerce;
  Rx<OwnerModel?> get ownerInfo;
  RxString get persistedOwnerId;
  RxString get searchQuery;
  RxString get selectedCategory;
  RxList<String> get availableCategories;
  RxBool get isGridView;
  RxString get sortBy;
  RxList<MenuModel> get filteredMenu;
  RxList<MenuItemModel> get filteredMenuItems;

  // Getters
  String get currentOwnerId;

  // Métodos
  void clearPersistedOwnerId();
  void updateSearchQuery(String query);
  void selectCategory(String category);
  void clearFilters();
  void setSortBy(String sortOption);
  void toggleViewMode();
}
*/
