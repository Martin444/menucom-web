import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'menu_controller.dart';
import 'filter_controller.dart';
import 'cart_controller.dart';

/// Controlador coordinador que integra MenuController, FilterController y CartController
/// Reemplaza al monolítico MenuHomeCartController manteniendo compatibilidad con la UI
class HomeController extends GetxController {
  // Controladores especializados
  late final MenuController _menuController;
  late final FilterController _filterController;
  late final CartController _cartController;

  // Estado adicional específico de la vista Home
  final RxBool _isGridView = true.obs;
  final RxString _sortBy = 'none'.obs; // 'none', 'name', 'price_low', 'price_high'

  HomeController({
    MenuController? menuController,
    FilterController? filterController,
    CartController? cartController,
  }) {
    _menuController = menuController ?? Get.find<MenuController>();
    _filterController = filterController ?? Get.find<FilterController>();
    _cartController = cartController ?? Get.find<CartController>();
  }

  // === GETTERS PÚBLICOS PARA COMPATIBILIDAD CON UI EXISTENTE ===

  // Datos del menú
  List<MenuModel>? get listMenu => _menuController.menus;
  List<MenuItemModel> get listMenuItems => _menuController.allMenuItems;
  OwnerModel? get ownerInfo => _menuController.owner;
  String get nameComerce => _menuController.owner?.name ?? '';
  String get currentOwnerId => _menuController.owner?.id ?? '';

  // Estado de carga y errores
  bool get isLoadHomeItems => _menuController.isLoading || _filterController.isLoading;
  String get errorText => _menuController.error;
  bool get hasError => _menuController.hasError;

  // Filtros y búsqueda
  String get searchQuery => _filterController.searchQuery;
  String get selectedCategory => _filterController.selectedCategory;
  List<String> get availableCategories => _filterController.availableCategories;
  List<MenuItemModel> get filteredMenuItems => _getFilteredAndSortedItems();

  // Vista
  bool get isGridView => _isGridView.value;
  String get sortBy => _sortBy.value;

  // Carrito
  List<CartItem> get cartItems => _cartController.cartItems;
  double get cartTotal => _cartController.total;
  double get cartSubtotal => _cartController.subtotal;
  double get cartTax => _cartController.tax;
  int get cartItemCount => _cartController.itemCount;
  int get cartTotalQuantity => _cartController.totalQuantity;
  bool get hasItemsInCart => _cartController.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _setupControllerListeners();
  }

  /// Configura listeners entre controladores
  void _setupControllerListeners() {
    // Cuando se carga un menú, actualizar filtros
    ever(_menuController.allMenuItems.obs, (List<MenuItemModel> items) {
      _filterController.setMenuItems(items);
    });

    // Cuando cambian los items filtrados, aplicar ordenamiento
    ever(_filterController.filteredItems.obs, (_) => update());
    ever(_sortBy, (_) => update());
  }

  // === MÉTODOS PÚBLICOS PARA LA UI ===

  /// Carga el menú de un propietario
  Future<void> loadMenu(String ownerId) async {
    await _menuController.loadMenu(ownerId);
  }

  // ========================================
  // MÉTODO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
  // ========================================
  // Este método no tiene referencias desde la UI.
  // RECOMENDACIÓN: Mantener comentado hasta que se implemente refresh manual
  // ========================================

  /*
  /// Recarga el menú actual
  Future<void> refreshMenu() async {
    await _menuController.refreshMenu();
  }
  */

  // === MÉTODOS DE FILTRADO Y BÚSQUEDA ===

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    _filterController.updateSearchQuery(query);
  }

  /// Selecciona/deselecciona una categoría
  void selectCategory(String category) {
    _filterController.selectCategory(category);
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _filterController.clearFilters();
    _sortBy.value = 'none';
  }

  /// Establece el ordenamiento
  void setSortBy(String sortOption) {
    _sortBy.value = sortOption;
    update();
  }

  /// Alterna entre vista de cuadrícula y lista
  void toggleViewMode() {
    _isGridView.value = !_isGridView.value;
    update();
  }

  // === MÉTODOS DEL CARRITO ===

  /// Añade un item al carrito
  void addToCart(MenuItemModel item, {int quantity = 1}) {
    _cartController.addItem(item, quantity: quantity);
  }

  /// Remueve un item del carrito
  void removeFromCart(String itemId) {
    _cartController.removeItem(itemId);
  }

  /// Incrementa la cantidad de un item en el carrito
  void incrementCartItem(String itemId) {
    _cartController.incrementItem(itemId);
  }

  /// Decrementa la cantidad de un item en el carrito
  void decrementCartItem(String itemId) {
    _cartController.decrementItem(itemId);
  }

  /// Actualiza la cantidad de un item en el carrito
  void updateCartItemQuantity(String itemId, int quantity) {
    _cartController.updateItemQuantity(itemId, quantity);
  }

  /// Limpia el carrito completamente
  void clearCart() {
    _cartController.clearCart();
  }

  /// Obtiene la cantidad de un item en el carrito
  int getCartItemQuantity(String itemId) {
    return _cartController.getItemQuantity(itemId);
  }

  /// Verifica si un item está en el carrito
  bool isItemInCart(String itemId) {
    return _cartController.containsItem(itemId);
  }

  /// Obtiene el resumen del carrito para checkout
  Map<String, dynamic> getCartSummary() {
    return _cartController.getCartSummary();
  }

  /// Convierte el carrito a formato para crear orden
  List<OrderItemModel> getOrderItems() {
    return _cartController.toOrderItems();
  }

  // === MÉTODOS PRIVADOS ===

  /// Obtiene los items filtrados y ordenados
  List<MenuItemModel> _getFilteredAndSortedItems() {
    List<MenuItemModel> items = List.from(_filterController.filteredItems);

    switch (_sortBy.value) {
      case 'name':
        items.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'price_low':
        items.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_high':
        items.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'none':
      default:
        // Mantener orden original
        break;
    }

    return items;
  }

  // === MÉTODOS DE COMPATIBILIDAD (para migración gradual) ===

  // ========================================
  // MÉTODO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
  // ========================================
  // Este método no tiene referencias desde la UI y usa clearMenu que está comentado.
  // RECOMENDACIÓN: Mantener comentado hasta implementar funcionalidad completa
  // ========================================

  /*
  /// Limpia el ID del propietario persistido (compatibilidad)
  void clearPersistedOwnerId() {
    _menuController.clearMenu();
  }
  */

  /// Obtiene información específica de un item por ID
  MenuItemModel? getItemById(String itemId) {
    return _menuController.getItemById(itemId);
  }

  // ========================================
  // MÉTODOS NO UTILIZADOS - CANDIDATOS PARA ELIMINACIÓN
  // ========================================
  // Estos métodos fueron creados para funcionalidad avanzada de filtrado por precio
  // que no se implementó en la UI actual.
  // RECOMENDACIÓN: Mantener comentados hasta implementar filtrado avanzado
  // ========================================

  /*
  /// Obtiene items por rango de precio
  List<MenuItemModel> getItemsByPriceRange(double minPrice, double maxPrice) {
    return _filterController.getItemsByPriceRange(minPrice, maxPrice);
  }

  /// Obtiene el rango de precios actual
  Map<String, double> getPriceRange() {
    return _filterController.getPriceRange();
  }
  */

  /// Obtiene el tiempo de entrega estimado del carrito
  int get estimatedDeliveryTime => _cartController.estimatedDeliveryTime;
}
