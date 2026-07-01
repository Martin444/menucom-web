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

/// Controlador coordinador: wiring + inicializacion + navegacion multi-catalogo.
/// Los widgets deben usar los controllers especializados directamente:
///   Get.find<CatalogController>() para datos del catalogo
///   Get.find<FilterController>() para filtros y busqueda
///   Get.find<CartController>() para el carrito
class HomeController extends GetxController {
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

  // ── Datos del catalogo ──

  CatalogModel? get catalog => _catalogController.catalogResponse;
  Rx<CatalogModel?> get catalogRx => _catalogController.catalogResponseRx;

  String? get ownerId => _catalogController.ownerId;
  String get nameComerce =>
      _catalogController.catalogResponse?.commerce?['name']?.toString() ??
      _catalogController.catalogResponse?.owner?['name']?.toString() ??
      _catalogController.catalogResponse?.name ??
      '';
  String get currentOwnerId =>
      _catalogController.catalogResponse?.commerce?['id']?.toString() ??
      _catalogController.catalogResponse?.owner?['id']?.toString() ??
      _catalogController.catalogResponse?.id ??
      '';

  Map<String, dynamic>? get owner => _catalogController.catalogResponse?.owner;
  Map<String, dynamic>? get commerceData => _catalogController.catalogResponse?.commerce;
  String? get ownerName =>
      _catalogController.catalogResponse?.commerce?['name']?.toString() ??
      _catalogController.catalogResponse?.owner?['name']?.toString();
  String? get ownerPhotoUrl =>
      _catalogController.catalogResponse?.commerce?['logoUrl']?.toString() ??
      _catalogController.catalogResponse?.owner?['photoURL']?.toString();

  // ── Multi-catalogo ──

  List<CatalogModel> get catalogs => _catalogController.catalogs;
  RxList<CatalogModel> get catalogsRx => _catalogController.catalogsRx;
  int get selectedCatalogIndex => _catalogController.selectedCatalogIndex;
  RxInt get selectedCatalogIndexRx => _catalogController.selectedCatalogIndexRx;
  bool get hasMultipleCatalogs => _catalogController.hasMultipleCatalogs;

  // ── Estado de carga y errores ──

  bool get isLoadHomeItems => _catalogController.isLoading || _filterController.isLoading;
  RxBool get isLoadingRx => _catalogController.isLoadingRx;
  String get errorText => _catalogController.error;
  RxString get errorRx => _catalogController.errorRx;
  bool get hasError => _catalogController.hasError;

  // ── Vista ──

  bool get isGridView => _isGridView.value;
  RxBool get isGridViewRx => _isGridView;

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

  // ── Carrito (solo metodos de coordinacion que requieren update()) ──

  bool isItemInCart(CatalogItemModel item) => _cartController.containsItem(item.id);
  bool detectItemInList(CatalogItemModel item) => isItemInCart(item);

  void selectItem(CatalogItemModel item) {
    _cartController.toggleItem(item);
    _cartController.update();
    update();
  }

  void addquantityItem(CartItemModel item) {
    if (item.id != null) {
      _cartController.incrementItem(item.id!);
      update();
    }
  }

  void removequantityItem(CartItemModel item) {
    if (item.id != null) {
      _cartController.decrementItem(item.id!);
      update();
    }
  }

  int get estimatedDeliveryTime => _cartController.estimatedDeliveryTime;

  // ── Persistencia ──

  RxString get persistedOwnerId => _persistedOwnerId;
  RxString get persistedCommerceId => _persistedCommerceId;

  // ── Lifecycle ──

  @override
  void onInit() {
    super.onInit();
    _setupControllerListeners();
    initializeFromUrl();
  }

  void _setupControllerListeners() {
    ever(_catalogController.allMenuItemsRx, (List<CatalogItemModel> items) {
      _filterController.clearFilters();
      _filterController.setMenuItems(items);
    });

    ever(_filterController.sortedFilteredItemsRx, (_) => update());
  }

  // ── Inicializacion desde URL ──

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
      _catalogController.setLoading(false);
    }
  }

  // ── Carga de catalogos ──

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

  Future<void> loadPublicCatalogsByCommerce(String identifier) async {
    await _catalogController.loadPublicCatalogsByCommerce(identifier);

    if (_catalogController.catalogResponse != null) {
      final catalog = _catalogController.catalogResponse!;
      _persistedOwnerId.value = catalog.ownerId;
      _persistedCommerceId.value = catalog.commerceId ?? identifier;
      await _cartController.validateCartOwner(catalog.commerceId ?? catalog.ownerId ?? catalog.id);

      final commerceName =
          catalog.commerce?['name']?.toString() ?? catalog.owner?['name']?.toString() ?? catalog.name ?? 'MenuCom';
      HtmlMetadataHelper.updateCommerceMetadata(
        name: commerceName,
        logoUrl: catalog.commerce?['logoUrl']?.toString() ?? catalog.coverImageUrl,
        description: catalog.commerce?['description']?.toString() ?? catalog.description ?? 'Catálogo de productos y servicios',
      );
    }
  }

  @Deprecated('Usar loadPublicCatalogsByCommerce')
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

  // ── Helpers ──

  CatalogItemModel? getItemById(String itemId) {
    return _catalogController.getItemById(itemId);
  }
}
