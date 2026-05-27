import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../../../shared/utils/debouncer.dart';
import '../../../shared/utils/text_normalizer.dart';

class FilterController extends GetxController {
  final RxString _searchQuery = ''.obs;
  final RxList<CatalogItemModel> _filteredItems = <CatalogItemModel>[].obs;
  final RxList<CatalogItemModel> _sortedFilteredItems = <CatalogItemModel>[].obs;
  final RxList<String> _availableCategories = <String>[].obs;
  final RxList<String> _selectedCategories = <String>[].obs;
  final RxString _sortBy = 'none'.obs;
  final RxBool _isLoading = false.obs;

  final RxBool _showOnlyAvailable = false.obs;
  final RxBool _showOnlyOnSale = false.obs;
  final RxBool _showOnlyFeatured = false.obs;

  final RxDouble _minPrice = 0.0.obs;
  final RxDouble _maxPrice = double.infinity.obs;
  final RxDouble _priceUpperBound = 0.0.obs;

  late final Debouncer _searchDebouncer;

  List<CatalogItemModel> _allItems = [];

  String get searchQuery => _searchQuery.value;
  RxString get searchQueryRx => _searchQuery;

  List<CatalogItemModel> get filteredItems => _filteredItems;
  RxList<CatalogItemModel> get filteredItemsRx => _filteredItems;

  List<CatalogItemModel> get sortedFilteredItems => _sortedFilteredItems;
  RxList<CatalogItemModel> get sortedFilteredItemsRx => _sortedFilteredItems;

  List<String> get availableCategories => _availableCategories;
  RxList<String> get availableCategoriesRx => _availableCategories;

  List<String> get selectedCategories => _selectedCategories;
  RxList<String> get selectedCategoriesRx => _selectedCategories;

  String get sortBy => _sortBy.value;
  RxString get sortByRx => _sortBy;

  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;

  bool get showOnlyAvailable => _showOnlyAvailable.value;
  RxBool get showOnlyAvailableRx => _showOnlyAvailable;

  bool get showOnlyOnSale => _showOnlyOnSale.value;
  RxBool get showOnlyOnSaleRx => _showOnlyOnSale;

  bool get showOnlyFeatured => _showOnlyFeatured.value;
  RxBool get showOnlyFeaturedRx => _showOnlyFeatured;

  double get minPrice => _minPrice.value;
  RxDouble get minPriceRx => _minPrice;

  double get maxPrice => _maxPrice.value;
  RxDouble get maxPriceRx => _maxPrice;

  double get priceUpperBound => _priceUpperBound.value;
  RxDouble get priceUpperBoundRx => _priceUpperBound;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      _selectedCategories.isNotEmpty ||
      _showOnlyAvailable.value ||
      _showOnlyOnSale.value ||
      _showOnlyFeatured.value ||
      _minPrice.value > 0 ||
      _maxPrice.value < _priceUpperBound.value;

  int get filteredItemsCount => _filteredItems.length;
  int get totalItemsCount => _allItems.length;

  @override
  void onInit() {
    super.onInit();
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  }

  void setMenuItems(List<CatalogItemModel> items) {
    _allItems = items;
    _extractCategories();
    _updatePriceBounds();
    _applyFilters();
  }

  void _extractCategories() {
    final categories = <String>{};
    for (final item in _allItems) {
      if (item.category != null && item.category!.isNotEmpty) {
        categories.add(item.category!);
      }
      if (item.tags != null) {
        categories.addAll(item.tags!);
      }
      final ingredients = item.ingredientsList;
      categories.addAll(ingredients);
    }
    _availableCategories.value = categories.toList()..sort();
  }

  void _updatePriceBounds() {
    if (_allItems.isNotEmpty) {
      _priceUpperBound.value = _allItems.map((i) => i.price).reduce((a, b) => a > b ? a : b);
      _maxPrice.value = _priceUpperBound.value;
      _minPrice.value = 0.0;
    }
  }

  List<String> _getItemCategories(CatalogItemModel item) {
    final cats = <String>[];
    if (item.category != null && item.category!.isNotEmpty) {
      cats.add(item.category!);
    }
    if (item.tags != null) {
      cats.addAll(item.tags!);
    }
    cats.addAll(item.ingredientsList);
    return cats;
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    _searchDebouncer.run(_applyFilters);
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFilters();
  }

  void toggleAvailableOnly() {
    _showOnlyAvailable.value = !_showOnlyAvailable.value;
    _applyFilters();
  }

  void toggleOnSale() {
    _showOnlyOnSale.value = !_showOnlyOnSale.value;
    _applyFilters();
  }

  void toggleFeatured() {
    _showOnlyFeatured.value = !_showOnlyFeatured.value;
    _applyFilters();
  }

  void setPriceRange(double min, double max) {
    _minPrice.value = min;
    _maxPrice.value = max;
    _applyFilters();
  }

  void clearPriceRange() {
    _minPrice.value = 0.0;
    _maxPrice.value = _priceUpperBound.value;
    _applyFilters();
  }

  void setSortBy(String sortOption) {
    _sortBy.value = sortOption;
    _sortFilteredItems();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedCategories.clear();
    _sortBy.value = 'none';
    _showOnlyAvailable.value = false;
    _showOnlyOnSale.value = false;
    _showOnlyFeatured.value = false;
    _minPrice.value = 0.0;
    _maxPrice.value = _priceUpperBound.value;
    _applyFilters();
  }

  void _applyFilters() {
    _isLoading.value = true;

    try {
      List<CatalogItemModel> result = List.from(_allItems);

      if (_searchQuery.value.isNotEmpty) {
        result = _filterBySearchQuery(result, _searchQuery.value);
      }

      if (_selectedCategories.isNotEmpty) {
        result = result.where((item) {
          final itemCategories = _getItemCategories(item);
          return _selectedCategories.any((c) => itemCategories.contains(c));
        }).toList();
      }

      if (_showOnlyAvailable.value) {
        result = result.where((item) => item.isAvailable).toList();
      }

      if (_showOnlyOnSale.value) {
        result = result.where((item) => item.hasDiscount).toList();
      }

      if (_showOnlyFeatured.value) {
        result = result.where((item) => item.isFeatured).toList();
      }

      if (_minPrice.value > 0 || _maxPrice.value < _priceUpperBound.value) {
        result = result.where((item) =>
            item.price >= _minPrice.value && item.price <= _maxPrice.value).toList();
      }

      _filteredItems.value = result;
      _sortFilteredItems();
    } finally {
      _isLoading.value = false;
    }
  }

  void _sortFilteredItems() {
    List<CatalogItemModel> items = List.from(_filteredItems);

    switch (_sortBy.value) {
      case 'name':
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'none':
      default:
        break;
    }

    _sortedFilteredItems.value = items;
  }

  List<CatalogItemModel> _filterBySearchQuery(List<CatalogItemModel> items, String query) {
    final normalizedQuery = TextNormalizer.normalize(query);

    return items.where((item) {
      if (TextNormalizer.normalize(item.name).contains(normalizedQuery)) {
        return true;
      }

      if (item.description != null &&
          TextNormalizer.normalize(item.description!).contains(normalizedQuery)) {
        return true;
      }

      if (item.category != null &&
          TextNormalizer.normalize(item.category!).contains(normalizedQuery)) {
        return true;
      }

      final itemCategories = _getItemCategories(item);
      for (final cat in itemCategories) {
        if (TextNormalizer.normalize(cat).contains(normalizedQuery)) {
          return true;
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