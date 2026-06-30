import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'catalog_controller.dart';
import 'filter_controller.dart';
import 'cart_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menucom_catalog/core/helpers/html_metadata_helper.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/shared/utils/helpers/token_helper.dart';
import 'package:menucom_catalog/core/analytics_service.dart';
import 'package:menucom_catalog/core/analytics_events.dart';

/// Controlador coordinador que integra CatalogController, FilterController y CartController
/// Reemplaza al monolítico MenuHomeCartController manteniendo compatibilidad con la UI (Catalog architecture)
class HomeController extends GetxController {
  // Controladores especializados
  late final CatalogController _catalogController;
  late final FilterController _filterController;
  late final CartController _cartController;

  final RxBool _isGridView = true.obs;
  final RxString _persistedOwnerId = ''.obs;
  final RxString _persistedCommerceId = ''.obs;

  HomeController({
    CatalogController? catalogController,
    FilterController? filterController,
    CartController? cartController,
  }) {
    _catalogController = catalogController ?? Get.find<CatalogController>();
    _filterController = filterController ?? Get.find<FilterController>();
    _cartController = cartController ?? Get.find<CartController>();
  }

  // === GETTERS PÚBLICOS PARA COMPATIBILIDAD CON UI EXISTENTE ===

  // Datos del catálogo
  CatalogModel? get catalog => _catalogController.catalogResponse;
  Rx<CatalogModel?> get catalogRx => _catalogController.catalogResponseRx;
  
  List<CatalogItemModel> get listMenuItems => _catalogController.allMenuItems;
  RxList<CatalogItemModel> get listMenuItemsRx => _catalogController.allMenuItemsRx;
  
  // Compatibilidad con getters antiguos
  String? get ownerId => _catalogController.ownerId;
  String get nameComerce => _catalogController.catalogResponse?.commerce?['name']?.toString() ?? _catalogController.catalogResponse?.owner?['name']?.toString() ?? _catalogController.catalogResponse?.name ?? '';
  String get currentOwnerId => _catalogController.catalogResponse?.commerce?['id']?.toString() ?? _catalogController.catalogResponse?.owner?['id']?.toString() ?? _catalogController.catalogResponse?.id ?? '';

  // Datos del comercio (owner legacy + commerce nuevo)
  Map<String, dynamic>? get owner => _catalogController.catalogResponse?.owner;
  Map<String, dynamic>? get commerceData => _catalogController.catalogResponse?.commerce;
  String? get ownerName => _catalogController.catalogResponse?.commerce?['name']?.toString() ?? _catalogController.catalogResponse?.owner?['name']?.toString();
  String? get ownerPhotoUrl => _catalogController.catalogResponse?.commerce?['logoUrl']?.toString() ?? _catalogController.catalogResponse?.owner?['photoURL']?.toString();

  // Multi-catálogo
  List<CatalogModel> get catalogs => _catalogController.catalogs;
  RxList<CatalogModel> get catalogsRx => _catalogController.catalogsRx;
  int get selectedCatalogIndex => _catalogController.selectedCatalogIndex;
  RxInt get selectedCatalogIndexRx => _catalogController.selectedCatalogIndexRx;
  bool get hasMultipleCatalogs => _catalogController.hasMultipleCatalogs;

  // Estado de carga y errores
  bool get isLoadHomeItems => _catalogController.isLoading || _filterController.isLoading;
  RxBool get isLoadingRx => _catalogController.isLoadingRx;
  
  String get errorText => _catalogController.error;
  RxString get errorRx => _catalogController.errorRx;
  
  bool get hasError => _catalogController.hasError;

  // Filtros y búsqueda
  String get searchQuery => _filterController.searchQuery;
  RxString get searchQueryRx => _filterController.searchQueryRx;
  
  List<String> get selectedCategories => _filterController.selectedCategories;
  RxList<String> get selectedCategoriesRx => _filterController.selectedCategoriesRx;
  
  List<String> get availableCategories => _filterController.availableCategories;
  RxList<String> get availableCategoriesRx => _filterController.availableCategoriesRx;
  
  List<CatalogItemModel> get filteredMenuItems => _filterController.sortedFilteredItems;
  RxList<CatalogItemModel> get filteredMenuItemsRx => _filterController.sortedFilteredItemsRx;

  bool get isGridView => _isGridView.value;
  RxBool get isGridViewRx => _isGridView;

  String get sortBy => _filterController.sortBy;
  RxString get sortByRx => _filterController.sortByRx;

  bool get showOnlyAvailable => _filterController.showOnlyAvailable;
  RxBool get showOnlyAvailableRx => _filterController.showOnlyAvailableRx;

  bool get showOnlyOnSale => _filterController.showOnlyOnSale;
  RxBool get showOnlyOnSaleRx => _filterController.showOnlyOnSaleRx;

  bool get showOnlyFeatured => _filterController.showOnlyFeatured;
  RxBool get showOnlyFeaturedRx => _filterController.showOnlyFeaturedRx;

  double get minPrice => _filterController.minPrice;
  RxDouble get minPriceRx => _filterController.minPriceRx;

  double get maxPrice => _filterController.maxPrice;
  RxDouble get maxPriceRx => _filterController.maxPriceRx;

  double get priceUpperBound => _filterController.priceUpperBound;
  RxDouble get priceUpperBoundRx => _filterController.priceUpperBoundRx;

  // Carrito
  List<CartItemModel> get cartItems => _cartController.cartItems;
  RxList<CartItemModel> get cartItemsRx => _cartController.cartItemsRx;
  
  double get totalOrder => _cartController.total;
  RxDouble get totalOrderRx => _cartController.totalRx;
  
  double get cartTotal => _cartController.total;
  RxDouble get cartTotalRx => _cartController.totalRx;
  
  double get cartSubtotal => _cartController.subtotal;
  RxDouble get cartSubtotalRx => _cartController.subtotalRx;
  
  double get cartTax => _cartController.tax;
  RxDouble get cartTaxRx => _cartController.taxRx;
  
  int get cartItemCount => _cartController.itemCount;
  int get cartTotalQuantity => _cartController.totalQuantity;
  bool get hasItemsInCart => _cartController.isNotEmpty;

  // Para compatibilidad con MyCartPage y otros
  List<CartItemModel> get listMenuSelected => _cartController.cartItems;

  /// Verifica si un item ya está en el carrito
  bool isItemInCart(CatalogItemModel item) {
    return _cartController.containsItem(item.id);
  }

  /// Método de compatibilidad para detectar items (usado en grids)
  bool detectItemInList(CatalogItemModel item) {
    return isItemInCart(item);
  }

  /// Agrega un item al carrito (o lo remueve si ya está, según lógica de compatibilidad)
  void selectItem(CatalogItemModel item) {
    if (_cartController.containsItem(item.id)) {
      _cartController.removeItem(item.id);
    } else {
      _cartController.addItem(item);
    }
    _cartController.update();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _setupControllerListeners();
    initializeFromUrl();
  }

  /// Configura listeners entre controladores
  void _setupControllerListeners() {
    ever(_catalogController.allMenuItemsRx, (List<CatalogItemModel> items) {
      _filterController.setMenuItems(items);
    });

    ever(_filterController.sortedFilteredItemsRx, (_) => update());
  }

  // === MÉTODOS PÚBLICOS PARA LA UI ===

  /// Inicializa los datos del menú basado en la URL actual
  void initializeFromUrl() {
    final uri = Uri.base;

    final ownerId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

    final rawToken = uri.queryParameters['token'] ?? '';
    final decodedToken = Uri.decodeComponent(rawToken);
    final hasValidToken = rawToken.isNotEmpty;

    if (hasValidToken) {
      ACCESS_TOKEN = decryptAccessToken(decodedToken);
      API.setAccessToken(ACCESS_TOKEN);
    }

    if (ownerId.isNotEmpty) {
      if (hasValidToken) {
        loadMenu(ownerId);
      } else {
        loadPublicCatalogsByCommerce(ownerId);
      }
    } else {
      // Si no hay ownerId, dejamos de cargar
      _catalogController.setLoading(false);
    }
  }

  /// Carga un catálogo específico (con auth)
  Future<void> loadMenu(String catalogId) async {
    await _catalogController.loadMenu(catalogId);

    if (_catalogController.catalogResponse != null) {
      final catalog = _catalogController.catalogResponse!;
      _persistedOwnerId.value = catalog.ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? '';
      await _cartController.validateCartOwner(catalog.commerceId ?? catalog.ownerId ?? catalog.id);

      HtmlMetadataHelper.updateCommerceMetadata(
        name: catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom',
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
  }

  /// Carga un catálogo público sin autenticación
  /// Usado cuando el usuario no está logeado
  Future<void> loadPublicMenu(String catalogId) async {
    await _catalogController.loadPublicMenu(catalogId);

    if (_catalogController.catalogResponse != null) {
      final catalog = _catalogController.catalogResponse!;
      _persistedOwnerId.value = catalog.ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? '';
      await _cartController.validateCartOwner(catalog.commerceId ?? catalog.ownerId ?? catalog.id);

      HtmlMetadataHelper.updateCommerceMetadata(
        name: catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom',
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
  }

  /// Carga catálogos públicos por identificador de comercio (slug o UUID)
  /// Reemplaza al obsoleto loadPublicCatalogsByOwnerId
  Future<void> loadPublicCatalogsByCommerce(String identifier) async {
    await _catalogController.loadPublicCatalogsByCommerce(identifier);

    if (_catalogController.catalogResponse != null) {
      final catalog = _catalogController.catalogResponse!;
      _persistedOwnerId.value = catalog.ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? identifier;
      await _cartController.validateCartOwner(catalog.commerceId ?? catalog.ownerId ?? catalog.id);

      final commerceName = catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom';
      HtmlMetadataHelper.updateCommerceMetadata(
        name: commerceName,
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.commerce?['description']?.toString() ?? catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
  }

  /// @deprecated Usar loadPublicCatalogsByCommerce
  Future<void> loadPublicCatalogsByOwnerId(String ownerId) async {
    await _catalogController.loadPublicCatalogsByOwnerId(ownerId);

    if (_catalogController.catalogResponse != null) {
      final catalog = _catalogController.catalogResponse!;
      _persistedOwnerId.value = ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? '';
      await _cartController.validateCartOwner(ownerId);

      HtmlMetadataHelper.updateCommerceMetadata(
        name: catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom',
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
  }

  /// Selecciona un catálogo por índice
  void selectCatalog(int index) {
    _catalogController.selectCatalog(index);
    final catalog = _catalogController.catalogResponse;
    if (catalog != null) {
      _persistedOwnerId.value = catalog.ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? '';
      HtmlMetadataHelper.updateCommerceMetadata(
        name: catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom',
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
    _filterController.clearFilters();
    _filterController.setMenuItems(_catalogController.allMenuItems);
    update();

    if (catalog != null) {
      AnalyticsService().logEvent(
        name: AnalyticsEvents.catalogSelected,
        parameters: {
          AnalyticsParams.catalogId: catalog.id,
          AnalyticsParams.catalogName: catalog.name ?? '',
        },
      );
    }
  }

  /// Getter para el owner ID (compatibilidad con órdenes)
  RxString get persistedOwnerId => _persistedOwnerId;

  /// Getter para el commerce ID (multi-tenant)
  RxString get persistedCommerceId => _persistedCommerceId;

  /// Aumenta la cantidad de un item en el carrito
  void addquantityItem(CartItemModel item) {
    if (item.id != null) {
      _cartController.incrementItem(item.id!);
      update();
    }
  }

  /// Disminuye la cantidad de un item en el carrito
  void removequantityItem(CartItemModel item) {
    if (item.id != null) {
      _cartController.decrementItem(item.id!);
      update();
    }
  }

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    _filterController.updateSearchQuery(query);
  }

  /// Alterna selección de categoría (multi-select)
  void toggleCategory(String category) {
    _filterController.toggleCategory(category);
  }

  void toggleAvailableOnly() {
    _filterController.toggleAvailableOnly();
  }

  void toggleOnSale() {
    _filterController.toggleOnSale();
  }

  void toggleFeatured() {
    _filterController.toggleFeatured();
  }

  void setPriceRange(double min, double max) {
    _filterController.setPriceRange(min, max);
  }

  void clearPriceRange() {
    _filterController.clearPriceRange();
  }

  void clearFilters() {
    _filterController.clearFilters();
  }

  void setSortBy(String sortOption) {
    _filterController.setSortBy(sortOption);
  }

  /// Alterna entre vista de cuadrícula y lista
  void toggleViewMode() {
    _isGridView.value = !_isGridView.value;
    update();
    AnalyticsService().logEvent(
      name: AnalyticsEvents.viewModeChanged,
      parameters: {
        AnalyticsParams.viewMode: _isGridView.value ? 'grid' : 'list',
      },
    );
  }

  // === MÉTODOS DEL CARRITO ===

  /// Añade un item al carrito
  void addToCart(CatalogItemModel item, {int quantity = 1}) {
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

  /// Verifica si un item está en el carrito (por ID)
  bool isItemIdInCart(String itemId) {
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

  CatalogItemModel? getItemById(String itemId) {
    return _catalogController.getItemById(itemId);
  }

  /// Obtiene el tiempo de entrega estimado do carrito
  int get estimatedDeliveryTime => _cartController.estimatedDeliveryTime;
}
