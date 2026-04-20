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
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Lista plana de todos los items para facilitar búsquedas y filtros
  final RxList<CatalogItemModel> _allMenuItems = <CatalogItemModel>[].obs;

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

  // El propietario se maneja a través de ownerId en CatalogModel
  String? get ownerId => _catalogResponse.value?.ownerId;
  
  // En la nueva arquitectura, CatalogModel ya es el contenedor de items
  CatalogModel? get currentCatalog => _catalogResponse.value;

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
        _catalogResponse.value = catalogs.first;
        _flattenMenuItems();
      } else {
        _error.value = 'No se encontraron catálogos públicos';
      }
    } catch (e) {
      _error.value = 'Error al carregar catálogos: ${e.toString()}';
      _catalogResponse.value = null;
      _allMenuItems.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Aplana todos los items del catálogo en una sola lista
  void _flattenMenuItems() {
    final items = _catalogResponse.value?.items ?? [];
    _allMenuItems.value = items;
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

