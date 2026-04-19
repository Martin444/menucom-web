import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../../../shared/utils/debouncer.dart';
import '../../../shared/utils/text_normalizer.dart';

/// Controlador especializado para manejo de filtros y búsquedas
/// Trabaja con los modelos de catálogo (Catalog architecture)
class FilterController extends GetxController {
  // Estado reactivo
  final RxString _searchQuery = ''.obs;
  final RxList<CatalogItemModel> _filteredItems = <CatalogItemModel>[].obs;
  final RxList<String> _availableCategories = <String>[].obs;
  final RxString _selectedCategory = ''.obs;
  final RxBool _isLoading = false.obs;

  // Debouncer para búsqueda
  late final Debouncer _searchDebouncer;

  // Lista original de items
  List<CatalogItemModel> _allItems = [];

  // Getters públicos (solo lectura)
  String get searchQuery => _searchQuery.value;
  RxString get searchQueryRx => _searchQuery;

  List<CatalogItemModel> get filteredItems => _filteredItems;
  RxList<CatalogItemModel> get filteredItemsRx => _filteredItems;

  List<String> get availableCategories => _availableCategories;
  RxList<String> get availableCategoriesRx => _availableCategories;

  String get selectedCategory => _selectedCategory.value;
  RxString get selectedCategoryRx => _selectedCategory;

  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;

  bool get hasActiveFilters => searchQuery.isNotEmpty || selectedCategory.isNotEmpty;
  int get filteredItemsCount => _filteredItems.length;
  int get totalItemsCount => _allItems.length;

  @override
  void onInit() {
    super.onInit();
    _initializeDebouncer();
  }

  /// Inicializa el debouncer para las búsquedas
  void _initializeDebouncer() {
    _searchDebouncer = Debouncer(
      delay: const Duration(milliseconds: 300),
    );
  }

  /// Establece la lista inicial de items y extrae categorías
  void setMenuItems(List<CatalogItemModel> items) {
    _allItems = items;
    _extractCategories();
    _applyFilters();
  }

  /// Extrae categorías únicas de los atributos (ingredientes)
  void _extractCategories() {
    final categories = <String>{};
    for (final item in _allItems) {
      final ingredients = item.attributes?['ingredients'];
      if (ingredients is List) {
        for (var ingredient in ingredients) {
          categories.add(ingredient.toString());
        }
      }
    }
    _availableCategories.value = categories.toList()..sort();
  }

  /// Actualiza la consulta de búsqueda con debouncing
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    _searchDebouncer.run(_applyFilters);
  }

  /// Selecciona/deselecciona una categoría
  void selectCategory(String category) {
    if (_selectedCategory.value == category) {
      _selectedCategory.value = '';
    } else {
      _selectedCategory.value = category;
    }
    _applyFilters();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _searchQuery.value = '';
    _selectedCategory.value = '';
    _applyFilters();
  }

  /// Aplica todos los filtros activos
  void _applyFilters() {
    _isLoading.value = true;

    try {
      List<CatalogItemModel> result = List.from(_allItems);

      // Aplicar filtro de búsqueda
      if (_searchQuery.value.isNotEmpty) {
        result = _filterBySearchQuery(result, _searchQuery.value);
      }

      // Aplicar filtro de categoría
      if (_selectedCategory.value.isNotEmpty) {
        result = result.where((item) {
          final ingredients = item.attributes?['ingredients'];
          if (ingredients is List) {
            return ingredients.map((e) => e.toString()).contains(_selectedCategory.value);
          }
          return false;
        }).toList();
      }

      _filteredItems.value = result;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filtra items por consulta de búsqueda
  List<CatalogItemModel> _filterBySearchQuery(List<CatalogItemModel> items, String query) {
    final normalizedQuery = TextNormalizer.normalize(query);

    return items.where((item) {
      // Buscar en el nombre
      final normalizedName = TextNormalizer.normalize(item.name);
      if (normalizedName.contains(normalizedQuery)) {
        return true;
      }

      // Buscar en los ingredientes (dentro de attributes)
      final ingredients = item.attributes?['ingredients'];
      if (ingredients is List) {
        for (final ingredient in ingredients) {
          final normalizedIngredient = TextNormalizer.normalize(ingredient.toString());
          if (normalizedIngredient.contains(normalizedQuery)) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }

  @override
  void onClose() {
    _searchDebouncer.dispose();
    super.onClose();
  }
}

