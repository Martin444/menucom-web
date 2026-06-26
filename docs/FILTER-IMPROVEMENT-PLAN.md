---
tags:
  - domain/catalog
  - repo/catalog
  - type/plan
  - status/in-progress
aliases:
  - Filter Improvement Plan
  - Mejora de Filtros
---
# Plan de Mejora de Filtros - Menucom Catalog

**Fecha:** Mayo 2026  
**Estado:** Planificacion  
**Archivos principales afectados:**
- `lib/features/home/controllers/filter_controller.dart`
- `lib/features/home/controllers/home_controller.dart`
- `lib/features/home/presentation/widgets/search_filter_bar.dart`
- `lib/features/home/presentation/widgets/filter_summary_widget.dart`

---

## Estado Actual

### Que funciona hoy
- Busqueda por texto con normalizacion (quita acentos, lowercase)
- Filtro por una sola "categoria" (extraida de `attributes['ingredients']`)
- Debounce de 300ms en busqueda
- Ordenamiento por nombre, precio ascendente/descendente
- Widget de resumen de filtros activos con boton de limpiar

### Que falta / esta roto
- Solo se puede seleccionar **una** categoria a la vez
- Las categorias se extraen de `attributes['ingredients']` en vez de `category` / `tags`
- No hay filtro por precio (rango)
- No hay filtro por disponibilidad (`isAvailable`)
- No hay filtro por ofertas (`discountPrice`)
- No hay filtro por destacados (`isFeatured`)
- No hay filtro por tags
- Bug de tipo en `ingredients` (String vs List)
- Fuga de memoria en `TextEditingController`
- Filtros se recalculan en cada rebuild del widget

---

## Fase 1 — Correccion de Bugs y Alineacion con Modelo

**Objetivo:** Arreglar bugs criticos y usar los campos correctos del modelo.  
**Prioridad:** Alta  
**Estimacion:** 1-2 dias

### Tarea 1.1: Corregir tipo de `ingredients`

**Problema:** `FilterController` trata `ingredients` como `List`, pero `CatalogItemTile` lo castea como `String`.

**Solucion:**
1. Verificar el tipo real que devuelve la API
2. Normalizar en `CatalogItemModel.fromJson()` para que siempre sea `List<String>`
3. Actualizar `CatalogItemTile` para usar la lista normalizada

```dart
// En CatalogItemModel, agregar helper:
List<String> get ingredientsList {
  if (attributes == null) return [];
  final raw = attributes!['ingredients'];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String) return raw.split(',').map((e) => e.trim()).toList();
  return [];
}
```

### Tarea 1.2: Corregir fuga de TextEditingController

**Problema:** Se crea un nuevo `TextEditingController` en cada rebuild.

**Solucion:** Convertir `SearchFilterBar` a `StatefulWidget` con dispose:

```dart
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});
  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ... usar _searchController en lugar de crear uno nuevo
}
```

### Tarea 1.3: Usar `category` y `tags` del modelo

**Problema:** `_extractCategories()` ignora `category` y `tags`.

**Solucion:** Reescribir extraccion con prioridad:

```dart
void _extractCategories() {
  final categories = <String>{};
  for (final item in _allItems) {
    // Prioridad 1: campo category del modelo
    if (item.category != null && item.category!.isNotEmpty) {
      categories.add(item.category!);
    }
    // Prioridad 2: tags del modelo
    if (item.tags != null) {
      categories.addAll(item.tags!);
    }
    // Prioridad 3: ingredients de attributes (fallback)
    final ingredients = item.attributes?['ingredients'];
    if (ingredients is List) {
      for (var ing in ingredients) {
        categories.add(ing.toString());
      }
    }
  }
  _availableCategories.value = categories.toList()..sort();
}
```

### Tarea 1.4: Cachear resultado de filtros + sort

**Problema:** `_getFilteredAndSortedItems()` recalcula en cada rebuild.

**Solucion:** Mover la logica de sort a `FilterController` y emitir resultado cached:

```dart
// En FilterController, agregar:
final RxList<CatalogItemModel> _sortedFilteredItems = <CatalogItemModel>[].obs;
RxList<CatalogItemModel> get sortedFilteredItemsRx => _sortedFilteredItems;

void setSortBy(String sortBy) {
  _sortBy.value = sortBy;
  _applyFiltersAndSort();
}

void _applyFiltersAndSort() {
  _applyFilters(); // ya existe
  _sortItems();
}

void _sortItems() {
  List<CatalogItemModel> items = List.from(_filteredItems);
  switch (_sortBy.value) {
    case 'name': items.sort((a, b) => a.name.compareTo(b.name)); break;
    case 'price_low': items.sort((a, b) => a.price.compareTo(b.price)); break;
    case 'price_high': items.sort((a, b) => b.price.compareTo(a.price)); break;
  }
  _sortedFilteredItems.value = items;
}
```

---

## Fase 2 — Multi-seleccion y Nuevos Filtros

**Objetivo:** Agregar filtros avanzados usando datos del modelo.  
**Prioridad:** Media-Alta  
**Estimacion:** 3-4 dias

### Tarea 2.1: Seleccion multiple de categorias

**Cambio en FilterController:**

```dart
// Cambiar de:
final RxString _selectedCategory = ''.obs;

// A:
final RxList<String> _selectedCategories = <String>[].obs;

void toggleCategory(String category) {
  if (_selectedCategories.contains(category)) {
    _selectedCategories.remove(category);
  } else {
    _selectedCategories.add(category);
  }
  _applyFilters();
}

void clearCategories() {
  _selectedCategories.clear();
  _applyFilters();
}

bool isCategorySelected(String category) {
  return _selectedCategories.contains(category);
}
```

**Cambio en filtro:**
```dart
// En _applyFilters:
if (_selectedCategories.isNotEmpty) {
  result = result.where((item) {
    final itemCategories = _getItemCategories(item);
    return _selectedCategories.any((c) => itemCategories.contains(c));
  }).toList();
}
```

### Tarea 2.2: Filtro de disponibilidad

```dart
final RxBool _showOnlyAvailable = false.obs;

void toggleAvailableOnly() {
  _showOnlyAvailable.value = !_showOnlyAvailable.value;
  _applyFilters();
}

// En _applyFilters:
if (_showOnlyAvailable.value) {
  result = result.where((item) => item.isAvailable).toList();
}
```

### Tarea 2.3: Filtro de ofertas (descuento)

```dart
final RxBool _showOnlyOnSale = false.obs;

void toggleOnSale() {
  _showOnlyOnSale.value = !_showOnlyOnSale.value;
  _applyFilters();
}

// En _applyFilters:
if (_showOnlyOnSale.value) {
  result = result.where((item) => item.discountPrice != null && item.discountPrice! < item.price).toList();
}
```

### Tarea 2.4: Filtro de destacados

```dart
final RxBool _showOnlyFeatured = false.obs;

void toggleFeatured() {
  _showOnlyFeatured.value = !_showOnlyFeatured.value;
  _applyFilters();
}

// En _applyFilters:
if (_showOnlyFeatured.value) {
  result = result.where((item) => item.isFeatured).toList();
}
```

### Tarea 2.5: Filtro de rango de precio

```dart
final RxDouble _minPrice = 0.0.obs;
final RxDouble _maxPrice = double.infinity.obs;
final RxDouble _priceUpperBound = 0.0.obs; // maximo precio del catalogo

void setPriceRange(double min, double max) {
  _minPrice.value = min;
  _maxPrice.value = max;
  _applyFilters();
}

void resetPriceRange() {
  _minPrice.value = 0.0;
  _maxPrice.value = _priceUpperBound.value;
  _applyFilters();
}

// En _applyFilters, calcular _priceUpperBound:
void _updatePriceBounds() {
  if (_allItems.isNotEmpty) {
    _priceUpperBound.value = _allItems.map((i) => i.price).reduce((a, b) => a > b ? a : b);
  }
}

// Filtro:
if (_minPrice.value > 0 || _maxPrice.value < _priceUpperBound.value) {
  result = result.where((item) =>
    item.price >= _minPrice.value && item.price <= _maxPrice.value
  ).toList();
}
```

### Tarea 2.6: Actualizar UI — Barra de filtros expandida

Agregar toggle chips y sliders en `SearchFilterBar`:

```
[Buscar...] [Ordenar ▼]
[Categoria1] [Categoria2] [Categoria3] ...   (multi-select)
[✓ Solo disponibles] [✓ En oferta] [✓ Destacados]
[Precio: ====slider====  $500 - $5000]
```

Usar `ExpansionTile` o `AnimatedContainer` para mostrar/ocultar filtros avanzados.

---

## Fase 3 — UX Avanzada

**Objetivo:** Pulir la experiencia de filtro y agregar features de calidad.  
**Prioridad:** Baja-Media  
**Estimacion:** 2-3 dias

### Tarea 3.1: Contador de items por categoria

Mostrar cantidad junto a cada chip:

```dart
ChoiceChip(
  label: Text('${category} (${_getCountForCategory(category)})'),
  selected: controller.isCategorySelected(category),
  ...
)
```

### Tarea 3.2: Persistencia de filtros en URL

Guardar filtros activos como query params para poder compartir URLs filtradas:

```
/catalog/uuid?search=pizza&categories=italiano,rapido&onSale=true
```

Usar `Get.routing` o `Uri.base` para leer/escribir params.

### Tarea 3.3: Animaciones en filtros

- Animar chips al aparecer/desaparecer con `AnimatedWrap`
- Animar el collapsible de filtros avanzados con `AnimatedSize`
- Feedback visual rapido al seleccionar/deseleccionar

### Tarea 3.4: Estado "Sin resultados" mejorado

Mostrar sugerencias cuando no hay resultados:
- "No encontramos resultados para 'xyz'"
- Botones para: limpiar filtros, buscar en todas las categorias
- Mostrar categorias que SI tienen resultados

### Tarea 3.5: Busquedas recientes

Guardar ultimas 5 busquedas en `SharedPreferences` y mostrarlas como sugerencias al hacer focus en el campo de busqueda.

---

## Diagrama de Flujo de Filtros

```
Usuario interactua con UI
        │
        ▼
SearchFilterBar / FilterSummaryWidget
        │
        ▼
HomeController.updateSearchQuery()  /  .selectCategory()  /  .toggleAvailableOnly()  /  ...
        │
        ▼
FilterController (estado centralizado)
  ├── _searchQuery: RxString
  ├── _selectedCategories: RxList<String>
  ├── _showOnlyAvailable: RxBool
  ├── _showOnlyOnSale: RxBool
  ├── _showOnlyFeatured: RxBool
  ├── _minPrice / _maxPrice: RxDouble
  ├── _sortBy: RxString
        │
        ▼
_applyFilters() → _applySort() → _sortedFilteredItems
        │
        ▼
UI se reconstruye (GetBuilder / Obx)
        │
        ▼
ResponsiveItemsGrid muestra resultado
```

---

## Dependencias entre Tareas

```
1.1 (fix ingredients type)
  └──→ 2.1 (multi-categoria usa ingredients corregido)
1.2 (fix TextEditingController)
  └──→ 2.6 (UI de filtros necesita controller estables)
1.3 (usar category/tags del modelo)
  └──→ 2.1 (multi-categoria con datos correctos)
1.4 (cachear filtros+sort)
  └──→ 2.2-2.5 (todos los nuevos filtros necesitan cache)
2.1-2.6 (todos los filtros nuevos)
  └──→ 3.1-3.5 (UX sobre filtros funcionales)
```

---

## Criterio de Aceptacion

- [ ] Todos los tests existentes pasan
- [ ] No hay fugas de memoria en controllers ni TextEditingControllers
- [ ] Los filtros se pueden combinar (buscar + categoria + precio + disponibles)
- [ ] Limpiar filtros resetea todo correctamente
- [ ] El resumen de filtros muestra todos los filtros activos
- [ ] Performance: filtros en <16ms para catalogos de hasta 500 items
- [ ] Responsive: filtros usables en mobile y desktop