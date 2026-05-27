import 'package:flutter_test/flutter_test.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/filter_controller.dart';

CatalogItemModel _makeItem({
  required String id,
  required String name,
  double price = 10.0,
  double? discountPrice,
  bool isAvailable = true,
  bool isFeatured = false,
  String? category,
  List<String>? tags,
  Map<String, dynamic>? attributes,
}) {
  return CatalogItemModel(
    id: id,
    catalogId: 'cat1',
    name: name,
    price: price,
    discountPrice: discountPrice,
    quantity: 1,
    status: 'available',
    isAvailable: isAvailable,
    isFeatured: isFeatured,
    category: category,
    tags: tags,
    attributes: attributes,
    displayOrder: 0,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  late FilterController controller;

  setUp(() {
    controller = FilterController();
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
  });

  group('multi-category selection', () {
    test('starts empty', () {
      expect(controller.selectedCategories, isEmpty);
    });

    test('toggles category on', () {
      controller.toggleCategory('Pizza');
      expect(controller.selectedCategories, ['Pizza']);
    });

    test('toggles category off', () {
      controller.toggleCategory('Pizza');
      controller.toggleCategory('Pizza');
      expect(controller.selectedCategories, isEmpty);
    });

    test('supports multiple categories', () {
      controller.toggleCategory('Pizza');
      controller.toggleCategory('Pasta');
      expect(controller.selectedCategories, ['Pizza', 'Pasta']);
    });

    test('filters items by selected categories', () {
      final items = [
        _makeItem(id: '1', name: 'Item1', category: 'Pizza'),
        _makeItem(id: '2', name: 'Item2', category: 'Pasta'),
        _makeItem(id: '3', name: 'Item3', category: 'Ensalada'),
      ];
      controller.setMenuItems(items);

      controller.toggleCategory('Pizza');
      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '1');

      controller.toggleCategory('Pasta');
      expect(controller.sortedFilteredItems.length, 2);
    });
  });

  group('available filter', () {
    test('shows all by default', () {
      final items = [
        _makeItem(id: '1', name: 'Available', isAvailable: true),
        _makeItem(id: '2', name: 'Unavailable', isAvailable: false),
      ];
      controller.setMenuItems(items);
      expect(controller.sortedFilteredItems.length, 2);
    });

    test('filters unavailable items when toggled', () {
      final items = [
        _makeItem(id: '1', name: 'Available', isAvailable: true),
        _makeItem(id: '2', name: 'Unavailable', isAvailable: false),
      ];
      controller.setMenuItems(items);

      controller.toggleAvailableOnly();
      expect(controller.showOnlyAvailable, true);
      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '1');
    });

    test('can be toggled off', () {
      final items = [
        _makeItem(id: '1', name: 'Available', isAvailable: true),
        _makeItem(id: '2', name: 'Unavailable', isAvailable: false),
      ];
      controller.setMenuItems(items);

      controller.toggleAvailableOnly();
      controller.toggleAvailableOnly();
      expect(controller.showOnlyAvailable, false);
      expect(controller.sortedFilteredItems.length, 2);
    });
  });

  group('on sale filter', () {
    test('filters items with discount', () {
      final items = [
        _makeItem(id: '1', name: 'Normal', price: 100),
        _makeItem(id: '2', name: 'OnSale', price: 100, discountPrice: 80),
      ];
      controller.setMenuItems(items);

      controller.toggleOnSale();
      expect(controller.showOnlyOnSale, true);
      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '2');
    });
  });

  group('featured filter', () {
    test('filters featured items', () {
      final items = [
        _makeItem(id: '1', name: 'Normal', isFeatured: false),
        _makeItem(id: '2', name: 'Featured', isFeatured: true),
      ];
      controller.setMenuItems(items);

      controller.toggleFeatured();
      expect(controller.showOnlyFeatured, true);
      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '2');
    });
  });

  group('price range filter', () {
    test('shows all by default', () {
      final items = [
        _makeItem(id: '1', name: 'Cheap', price: 100),
        _makeItem(id: '2', name: 'Expensive', price: 500),
      ];
      controller.setMenuItems(items);
      expect(controller.sortedFilteredItems.length, 2);
    });

    test('filters by price range', () {
      final items = [
        _makeItem(id: '1', name: 'Cheap', price: 100),
        _makeItem(id: '2', name: 'Mid', price: 300),
        _makeItem(id: '3', name: 'Expensive', price: 500),
      ];
      controller.setMenuItems(items);

      controller.setPriceRange(200, 400);
      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '2');
    });

    test('clears price range', () {
      final items = [
        _makeItem(id: '1', name: 'Cheap', price: 100),
        _makeItem(id: '2', name: 'Expensive', price: 500),
      ];
      controller.setMenuItems(items);

      controller.setPriceRange(200, 400);
      controller.clearPriceRange();
      expect(controller.sortedFilteredItems.length, 2);
    });
  });

  group('price bounds', () {
    test('calculates upper bound from items', () {
      final items = [
        _makeItem(id: '1', name: 'Cheap', price: 100),
        _makeItem(id: '2', name: 'Expensive', price: 500),
      ];
      controller.setMenuItems(items);
      expect(controller.priceUpperBound, 500);
    });

    test('sets maxPrice to upper bound on load', () {
      final items = [
        _makeItem(id: '1', name: 'Cheap', price: 100),
        _makeItem(id: '2', name: 'Expensive', price: 500),
      ];
      controller.setMenuItems(items);
      expect(controller.maxPrice, 500);
    });
  });

  group('clearFilters', () {
    test('resets search query', () {
      controller.setMenuItems([_makeItem(id: '1', name: 'Item')]);
      controller.updateSearchQuery('test');
      controller.clearFilters();
      expect(controller.searchQuery, '');
    });

    test('resets categories', () {
      controller.toggleCategory('Pizza');
      controller.clearFilters();
      expect(controller.selectedCategories, isEmpty);
    });

    test('resets sort', () {
      controller.setSortBy('name');
      controller.clearFilters();
      expect(controller.sortBy, 'none');
    });

    test('resets available filter', () {
      controller.toggleAvailableOnly();
      controller.clearFilters();
      expect(controller.showOnlyAvailable, false);
    });

    test('resets on sale filter', () {
      controller.toggleOnSale();
      controller.clearFilters();
      expect(controller.showOnlyOnSale, false);
    });

    test('resets featured filter', () {
      controller.toggleFeatured();
      controller.clearFilters();
      expect(controller.showOnlyFeatured, false);
    });

    test('resets price range', () {
      final items = [
        _makeItem(id: '1', name: 'Item', price: 100),
      ];
      controller.setMenuItems(items);
      controller.setPriceRange(50, 80);
      controller.clearFilters();
      expect(controller.minPrice, 0.0);
      expect(controller.maxPrice, controller.priceUpperBound);
    });

    test('restores all items after clear', () {
      final items = [
        _makeItem(id: '1', name: 'A', category: 'Pizza', isAvailable: false),
        _makeItem(id: '2', name: 'B', category: 'Pasta', isAvailable: true),
      ];
      controller.setMenuItems(items);

      controller.toggleCategory('Pizza');
      controller.toggleAvailableOnly();
      expect(controller.sortedFilteredItems.length, 0);

      controller.clearFilters();
      expect(controller.sortedFilteredItems.length, 2);
    });
  });

  group('hasActiveFilters', () {
    test('false with no filters', () {
      expect(controller.hasActiveFilters, false);
    });

    test('true when category selected', () {
      controller.toggleCategory('Pizza');
      expect(controller.hasActiveFilters, true);
    });

    test('true when available filter active', () {
      controller.toggleAvailableOnly();
      expect(controller.hasActiveFilters, true);
    });

    test('true when on sale filter active', () {
      controller.toggleOnSale();
      expect(controller.hasActiveFilters, true);
    });

    test('true when featured filter active', () {
      controller.toggleFeatured();
      expect(controller.hasActiveFilters, true);
    });

    test('true when price range set', () {
      final items = [_makeItem(id: '1', name: 'Item', price: 100)];
      controller.setMenuItems(items);
      controller.setPriceRange(10, 50);
      expect(controller.hasActiveFilters, true);
    });
  });

  group('combined filters', () {
    test('category + available + price', () {
      final items = [
        _makeItem(id: '1', name: 'Pizza barata', category: 'Pizza', price: 100, isAvailable: true),
        _makeItem(id: '2', name: 'Pizza cara', category: 'Pizza', price: 500, isAvailable: true),
        _makeItem(id: '3', name: 'Pizza no disp', category: 'Pizza', price: 200, isAvailable: false),
        _makeItem(id: '4', name: 'Pasta', category: 'Pasta', price: 150),
      ];
      controller.setMenuItems(items);

      controller.toggleCategory('Pizza');
      controller.toggleAvailableOnly();
      controller.setPriceRange(0, 300);

      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '1');
    });

    test('onSale + featured', () {
      final items = [
        _makeItem(id: '1', name: 'Normal', price: 100),
        _makeItem(id: '2', name: 'Featured on sale', price: 200, discountPrice: 150, isFeatured: true),
        _makeItem(id: '3', name: 'On sale', price: 200, discountPrice: 150, isFeatured: false),
      ];
      controller.setMenuItems(items);

      controller.toggleOnSale();
      controller.toggleFeatured();

      expect(controller.sortedFilteredItems.length, 1);
      expect(controller.sortedFilteredItems.first.id, '2');
    });
  });
}
