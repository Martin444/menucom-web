import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../../../shared/utils/debouncer.dart';
import '../../../shared/utils/text_normalizer.dart';

/// Controlador especializado para manejo de filtros y búsquedas
/// Trabaja con los modelos de menu_dart_api directamente
class FilterController extends GetxController {
  // Estado reactivo
  final RxString _searchQuery = ''.obs;
  final RxList<MenuItemModel> _filteredItems = <MenuItemModel>[].obs;
  final RxList<String> _availableCategories = <String>[].obs;
  final RxString _selectedCategory = ''.obs;
  final RxBool _isLoading = false.obs;

  // Debouncer para búsqueda
  late final Debouncer _searchDebouncer;

  // Lista original de items (proporcionada por MenuController)
  List<MenuItemModel> _allItems = [];

  // Getters públicos (solo lectura)
  String get searchQuery => _searchQuery.value;
  List<MenuItemModel> get filteredItems => _filteredItems;
  List<String> get availableCategories => _availableCategories;
  String get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
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
  void setMenuItems(List<MenuItemModel> items) {
    _allItems = items;
    _extractCategories();
    _applyFilters();
  }

  /// Extrae categorías únicas de los ingredientes
  void _extractCategories() {
    final categories = <String>{};
    for (final item in _allItems) {
      if (item.ingredients != null) {
        categories.addAll(item.ingredients!);
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
      List<MenuItemModel> result = List.from(_allItems);

      // Aplicar filtro de búsqueda
      if (_searchQuery.value.isNotEmpty) {
        result = _filterBySearchQuery(result, _searchQuery.value);
      }

      // Aplicar filtro de categoría
      if (_selectedCategory.value.isNotEmpty) {
        result = result.where((item) => item.ingredients?.contains(_selectedCategory.value) ?? false).toList();
      }

      _filteredItems.value = result;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filtra items por consulta de búsqueda
  List<MenuItemModel> _filterBySearchQuery(List<MenuItemModel> items, String query) {
    final normalizedQuery = TextNormalizer.normalize(query);

    return items.where((item) {
      // Buscar en el nombre
      final normalizedName = TextNormalizer.normalize(item.name ?? '');
      if (normalizedName.contains(normalizedQuery)) {
        return true;
      }

      // Buscar en los ingredientes
      if (item.ingredients != null) {
        for (final ingredient in item.ingredients!) {
          final normalizedIngredient = TextNormalizer.normalize(ingredient);
          if (normalizedIngredient.contains(normalizedQuery)) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }

  // ========================================
  // MÉTODOS NO UTILIZADOS - CANDIDATOS PARA ELIMINACIÓN
  // ========================================
  // Estos métodos fueron creados para filtrado avanzado por rango de precios
  // que no se implementó en la UI actual.
  // RECOMENDACIÓN: Mantener comentados hasta implementar filtrado avanzado
  // ========================================

  /*
  /// Obtiene items por rango de precio
  List<MenuItemModel> getItemsByPriceRange(double minPrice, double maxPrice) {
    return _filteredItems.where((item) {
      final price = item.price?.toDouble() ?? 0.0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  /// Obtiene el rango de precios de los items filtrados
  Map<String, double> getPriceRange() {
    if (_filteredItems.isEmpty) {
      return {'min': 0.0, 'max': 0.0};
    }

    final prices = _filteredItems.map((item) => item.price?.toDouble() ?? 0.0).where((price) => price > 0).toList();

    if (prices.isEmpty) {
      return {'min': 0.0, 'max': 0.0};
    }

    prices.sort();
    return {
      'min': prices.first,
      'max': prices.last,
    };
  }
  */

  @override
  void onClose() {
    _searchDebouncer.dispose();
    super.onClose();
  }
}
