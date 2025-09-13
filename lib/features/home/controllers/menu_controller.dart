import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';

/// Controlador especializado para manejo del menú principal
/// Responsable de cargar y gestionar los datos del menú usando menu_dart_api
class MenuController extends GetxController {
  final GetMenuUseCase _getMenuUseCase;

  // Estado reactivo
  final Rx<MenuResponse?> _menuResponse = Rx<MenuResponse?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Lista plana de todos los items para facilitar búsquedas y filtros
  final RxList<MenuItemModel> _allMenuItems = <MenuItemModel>[].obs;

  MenuController({GetMenuUseCase? getMenuUseCase}) : _getMenuUseCase = getMenuUseCase ?? GetMenuUseCase();

  // Getters públicos (solo lectura)
  MenuResponse? get menuResponse => _menuResponse.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<MenuItemModel> get allMenuItems => _allMenuItems;
  bool get hasData => _menuResponse.value != null;
  bool get hasError => _error.value.isNotEmpty;

  // Información del propietario
  OwnerModel? get owner => _menuResponse.value?.owner;
  List<MenuModel>? get menus => _menuResponse.value?.listmenus;

  @override
  void onInit() {
    super.onInit();
    // Se puede cargar el menú automáticamente si se conoce el ownerId
    // loadMenu('defaultOwnerId');
  }

  /// Carga el menú de un propietario específico
  Future<void> loadMenu(String ownerId) async {
    if (ownerId.isEmpty) {
      _error.value = 'ID del propietario no válido';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _getMenuUseCase.execute(ownerId);
      _menuResponse.value = response;

      // Crear lista plana de todos los items para facilitar búsquedas
      _flattenMenuItems();
    } catch (e) {
      _error.value = 'Error al cargar el menú: ${e.toString()}';
      _menuResponse.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================
  // MÉTODO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
  // ========================================
  // Este método no tiene referencias desde la UI.
  // Podría ser útil para funcionalidad futura de refresh manual.
  // RECOMENDACIÓN: Mantener comentado hasta que se implemente en UI
  // ========================================

  /*
  /// Recarga el menú actual
  Future<void> refreshMenu() async {
    if (_menuResponse.value?.owner?.id != null) {
      await loadMenu(_menuResponse.value!.owner!.id!);
    }
  }
  */

  /// Aplana todos los items de menú en una sola lista
  void _flattenMenuItems() {
    final items = <MenuItemModel>[];

    final menus = _menuResponse.value?.listmenus;
    if (menus != null) {
      for (final menu in menus) {
        if (menu.items != null) {
          items.addAll(menu.items!);
        }
      }
    }

    _allMenuItems.value = items;
  }

  /// Obtiene un item específico por ID
  MenuItemModel? getItemById(String itemId) {
    try {
      return _allMenuItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // MÉTODO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
  // ========================================
  // Este método no tiene referencias en ningún archivo del proyecto.
  // Fue creado durante el refactoring pero nunca se implementó en la UI.
  // RECOMENDACIÓN: Eliminar si no se planea usar en el futuro
  // ========================================

  /*
  /// Obtiene todos los items de un menú específico
  List<MenuItemModel> getItemsByMenuId(String menuId) {
    final menu = menus?.firstWhere((m) => m.id == menuId);
    return menu?.items ?? [];
  }
  */

  // ========================================
  // MÉTODO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
  // ========================================
  // Este método no tiene referencias desde la UI.
  // Podría ser útil para funcionalidad futura de logout o cambio de contexto.
  // RECOMENDACIÓN: Mantener comentado hasta que se implemente en UI
  // ========================================

  /*
  /// Limpia el estado del controlador
  void clearMenu() {
    _menuResponse.value = null;
    _allMenuItems.clear();
    _error.value = '';
  }
  */
}
