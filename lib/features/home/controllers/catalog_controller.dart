import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menu_dart_api/by_feature/catalog/data/usecase/get_public_catalog_by_id_usecase.dart';
import 'package:menu_dart_api/by_feature/catalog/data/usecase/get_public_catalogs_by_owner_id_usecase.dart';

class CatalogController extends GetxController {
  final GetCatalogByIdUseCase _getCatalogUseCase;
  final GetPublicCatalogByIdUseCase _getPublicCatalogUseCase;
  final GetPublicCatalogsByOwnerIdUseCase _getPublicCatalogsByOwnerIdUseCase;

  // Estado reactivo
  final Rx<CatalogModel?> _catalogResponse = Rx<CatalogModel?>(null);
  final RxBool _isLoading = true.obs;
  final RxString _error = ''.obs;

  // Lista plana de todos los items para facilitar búsquedas y filtros
  final RxList<CatalogItemModel> _allMenuItems = <CatalogItemModel>[].obs;

  // Soporte multi-catálogo
  final RxList<CatalogModel> _catalogs = <CatalogModel>[].obs;
  final RxInt _selectedCatalogIndex = 0.obs;

  CatalogController({
    GetCatalogByIdUseCase? getCatalogUseCase,
    GetPublicCatalogByIdUseCase? getPublicCatalogUseCase,
    GetPublicCatalogsByOwnerIdUseCase? getPublicCatalogsByOwnerIdUseCase,
  })  : _getCatalogUseCase = getCatalogUseCase ?? GetCatalogByIdUseCase(),
        _getPublicCatalogUseCase = getPublicCatalogUseCase ?? GetPublicCatalogByIdUseCase(),
        _getPublicCatalogsByOwnerIdUseCase = getPublicCatalogsByOwnerIdUseCase ?? GetPublicCatalogsByOwnerIdUseCase();

  // Getters públicos (solo lectura)
  CatalogModel? get catalogResponse => _catalogResponse.value;
  Rx<CatalogModel?> get catalogResponseRx => _catalogResponse;
  
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;
  
  String get error => _error.value;
  RxString get errorRx => _error;
  
  List<CatalogItemModel> get allMenuItems => _allMenuItems;
  RxList<CatalogItemModel> get allMenuItemsRx => _allMenuItems;
  
  bool get hasData => _catalogResponse.value != null;
  bool get hasError => _error.value.isNotEmpty;

  String? get ownerId => _catalogResponse.value?.ownerId;
  CatalogModel? get currentCatalog => _catalogResponse.value;

  // Getters multi-catálogo
  List<CatalogModel> get catalogs => _catalogs;
  RxList<CatalogModel> get catalogsRx => _catalogs;
  int get selectedCatalogIndex => _selectedCatalogIndex.value;
  RxInt get selectedCatalogIndexRx => _selectedCatalogIndex;
  bool get hasMultipleCatalogs => _catalogs.length > 1;

  /// Carga un catálogo específico por ID
  Future<void> loadMenu(String catalogId) async {
    if (catalogId.isEmpty) {
      _error.value = 'ID del catálogo no válido';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _getCatalogUseCase.execute(catalogId);
      _catalogResponse.value = response;

      // Crear lista plana de todos los items para facilitar búsquedas
      _flattenMenuItems();
    } catch (e) {
      _error.value = 'Error al cargar el catálogo: ${e.toString()}';
      _catalogResponse.value = null;
      _allMenuItems.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carga un catálogo público por ID (sin autenticación)
  /// Usado cuando el usuario no está logeado
  Future<void> loadPublicMenu(String catalogId) async {
    if (catalogId.isEmpty) {
      _error.value = 'ID del catálogo no válido';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _getPublicCatalogUseCase.execute(catalogId);
      _catalogResponse.value = response;

      _flattenMenuItems();
    } catch (e) {
      _error.value = 'Error al carregar o catálogo: ${e.toString()}';
      _catalogResponse.value = null;
      _allMenuItems.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carga catálogos públicos por ownerId (sin autenticación)
  Future<void> loadPublicCatalogsByOwnerId(String ownerId) async {
    if (ownerId.isEmpty) {
      _error.value = 'ID del owner no válido';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final catalogs = await _getPublicCatalogsByOwnerIdUseCase.execute(ownerId);
      if (catalogs.isNotEmpty) {
        _catalogs.value = catalogs;
        _selectedCatalogIndex.value = 0;
        _catalogResponse.value = catalogs.first;
        _flattenMenuItems();
      } else {
        _error.value = 'No se encontraron catálogos públicos';
      }
    } catch (e) {
      _error.value = 'Error al carregar catálogos: ${e.toString()}';
      _catalogResponse.value = null;
      _allMenuItems.clear();
      _catalogs.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Selecciona un catálogo por índice y actualiza items
  void selectCatalog(int index) {
    if (index < 0 || index >= _catalogs.length) return;
    _selectedCatalogIndex.value = index;
    _catalogResponse.value = _catalogs[index];
    _flattenMenuItems();
  }

  /// Selecciona un catálogo por ID
  void selectCatalogById(String id) {
    final index = _catalogs.indexWhere((c) => c.id == id);
    if (index >= 0) selectCatalog(index);
  }

  /// Aplana todos los items del catálogo en una sola lista
  void _flattenMenuItems() {
    final items = _catalogResponse.value?.items ?? [];
    _allMenuItems.value = items;
  }

  /// Permite establecer el estado de carga manualmente
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Obtiene un item específico por ID
  CatalogItemModel? getItemById(String itemId) {
    try {
      return _allMenuItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}

