# Code Review - Menucom Catalog

**Fecha:** Mayo 2026  
**Alcance:** Proyecto completo (lib/, controllers, widgets, API models)  
**Estado:** Fase 1 completada | Fase 2 y 3 pendientes

---

## Resumen General

App Flutter web para catálogos de productos usando **GetX** como gestor de estado, **menu_dart_api** como capa API, y **pu_material** como librería de componentes. La funcionalidad principal es mostrar un catálogo con búsqueda, filtros, ordenamiento y carrito.

---

## Bugs Criticos

### BUG-001: Inconsistencia de tipo en `attributes['ingredients']` ✅ RESUELTO

| Archivo | Problema | Solucion |
|---|---|---|
| `catalog_model.dart` | No existia un acceso tipado a ingredients | Agregado getter `ingredientsList` que normaliza String/List a `List<String>` |
| `catalog_item_tile.dart` | Hacia cast a `String` y `.split(',')` | Cambiado a `item.ingredientsList.isNotEmpty ? item.ingredientsList : null` |
| `filter_controller.dart` | Trataba `ingredients` como `List` sin normalizar | Ahora usa `item.ingredientsList` via el getter |

**Cambio aplicado:** Se agrego `ingredientsList` y `hasDiscount` como getters en `CatalogItemModel`:
```dart
List<String> get ingredientsList {
  if (attributes == null) return [];
  final raw = attributes!['ingredients'];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String && raw.isNotEmpty) return raw.split(',').map((e) => e.trim()).toList();
  return [];
}

bool get hasDiscount => discountPrice != null && discountPrice! < price;
```

---

### BUG-002: Fuga de memoria con TextEditingController ✅ RESUELTO

| Archivo | Problema | Solucion |
|---|---|---|
| `search_filter_bar.dart` | Creaba `TextEditingController()` en cada rebuild | Convertido de `StatelessWidget` a `StatefulWidget` con dispose |

**Cambio aplicado:**
- `_searchController` se crea en `initState()` y se libera en `dispose()`
- Sincronizacion del texto: solo actualiza el controller cuando el texto difiere del estado reactivo
- Se eliminaron imports innecesarios (`flutter/gestures.dart`)

---

### BUG-003: Mutacion in-place de lista filtrada ✅ RESUELTO

| Archivo | Problema | Solucion |
|---|---|---|
| `home_controller.dart` | `_getFilteredAndSortedItems()` recalculaba en cada rebuild | Eliminado; sort movido a `FilterController._sortFilteredItems()` con resultado cacheado en `_sortedFilteredItems` (RxList) |

**Cambio aplicado:**
- Sort delegado a `FilterController.setSortBy()` -> `_sortFilteredItems()` -> `_sortedFilteredItems`
- `HomeController.filteredMenuItems` ahora apunta a `_filterController.sortedFilteredItems`
- `HomeController` ya no tiene `_sortBy`; delega a `FilterController`
- Listener cambiado de `ever(_filterController.filteredItemsRx)` + `ever(_sortBy)` a `ever(_filterController.sortedFilteredItemsRx)`

---

## Problemas de Arquitectura

### ARCH-001: HomeController es un facade excesivo ⬜ Pendiente

| Archivo | Problema |
|---|---|
| `home_controller.dart` | Mucho proxy hacia sub-controllers |

**Prioridad:** Media (no bloquea funcionalidad)  
**Cambios realizados en Fase 1:** Se redujo ligeramente — se elimino `_sortBy`, `_getFilteredAndSortedItems()`, y `clearFilters()` ahora delega directamente. Quedan ~20 metodos proxy restantes.

---

### ARCH-002: `_getFilteredAndSortedItems()` se recalcula en cada rebuild ✅ RESUELTO

| Archivo | Solucion |
|---|---|
| `home_controller.dart` | Eliminado el getter que recalculaba |
| `filter_controller.dart` | Agregado `_sortedFilteredItems` (RxList) cacheado, se actualiza solo cuando cambian filtros o sort |

---

### ARCH-003: Categorias extraidas de attributes en vez del modelo ✅ RESUELTO

| Archivo | Cambio |
|---|---|
| `filter_controller.dart` | `_extractCategories()` ahora prioriza `category` > `tags` > `ingredientsList` |
| `filter_controller.dart` | Nuevo metodo `_getItemCategories()` combina las 3 fuentes |
| `filter_controller.dart` | Busqueda por texto ahora busca en `name`, `description`, `category`, y tags/ingredients |

**Cambio aplicado:**
```dart
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
```

---

### ARCH-004: Sin paginacion ⬜ Pendiente

| Archivo | Problema |
|---|---|
| `catalog_controller.dart` | `_flattenMenuItems()` carga todo en memoria |

**Prioridad:** Baja (catalogos actuales son pequenos)

---

## Filtros Faltantes (Datos Disponibles vs. Uso Actual)

| Campo del Modelo | Se Usa para Filtrar? | Tipo de Filtro Posible |
|---|---|---|
| `category` | ✅ Ahora se usa (via `_extractCategories` y `_getItemCategories`) | Filtro de categoria principal |
| `tags` | ✅ Ahora se usa (via `_extractCategories` y `_getItemCategories`) | Filtro multi-etiqueta |
| `isAvailable` | ❌ No se usa | Toggle "Solo disponibles" |
| `isFeatured` | ❌ No se usa | Toggle "Destacados" |
| `discountPrice` | ❌ No se usa (getter `hasDiscount` agregado) | Toggle "En oferta" |
| `price` | ✅ Solo para ordenar | Filtro de rango de precio (min/max) |
| `attributes['ingredients']` | ✅ Se usa (normalizado via `ingredientsList`) | Filtro de ingredientes |
| Texto (nombre) | ✅ Busqueda con normalizacion | Busqueda full-text |
| `description` | ✅ Ahora se incluye en busqueda | Busqueda ampliada |
| `catalogType` | ✅ Determina layout (menu/ropa) | Podria filtrar sub-tipos |

---

## Issues Menores

### MIN-001: `TextNormalizer` no maneja `ñ` correctamente ⬜ Pendiente

Reemplaza `ñ` por `n`, lo cual es correcto para busqueda fuzzy, pero pierde especificidad. Considerar busqueda que funcione en ambas formas.

**Prioridad:** Baja

### MIN-002: Debouncer no se cancela en `updateSearchQuery` ⬜ Pendiente

El estado reactivo `_searchQuery` se actualiza inmediatamente, pero los filtros se aplican con delay. Causa desincronizacion transientemente.

**Prioridad:** Baja

### MIN-003: Seleccion unica de categoria ⬜ Pendiente (Fase 2)

Solo permite una categoria a la vez. El UX natural esperaria seleccion multiple.

**Prioridad:** Media (planificado en Fase 2)

---

## Checklist de Correccion

- [x] BUG-001: Unificar tipo de `ingredients` en modelo y filtros → Agregado `ingredientsList` getter
- [x] BUG-002: Corregir fuga de TextEditingController en SearchFilterBar → Convertido a StatefulWidget
- [x] BUG-003: Clarificar copia de lista en sort → Sort movido a FilterController con cacheo
- [ ] ARCH-001: Evaluar reduccion de facade en HomeController → Parcialmente reducido
- [x] ARCH-002: Cachear resultado de filtro+sort en observable → `_sortedFilteredItems` RxList
- [x] ARCH-003: Usar `category` y `tags` del modelo para filtros → `_extractCategories()` prioriza modelo
- [ ] ARCH-004: Planificar paginacion para catalogos grandes
- [ ] MIN-001: Evaluar busqueda con/sin normalizacion de ñ
- [ ] MIN-002: Sincronizar debouncer con estado reactivo
- [ ] MIN-003: Habilitar seleccion multiple de categorias → Fase 2

---

## Cambios Realizados — Fase 1

| Archivo | Cambio |
|---|---|
| `menu_dart_api/.../catalog_model.dart` | Agregados getters `ingredientsList` y `hasDiscount` a `CatalogItemModel` |
| `filter_controller.dart` | Reescrito: `_extractCategories()` usa `category`/`tags`/`ingredientsList`; `_getItemCategories()` combina fuentes; busqueda en `description` y `category`; sort con `_sortedFilteredItems` cacheado; delegado `setSortBy()` y `clearFilters()` |
| `home_controller.dart` | Eliminados `_sortBy`, `_getFilteredAndSortedItems()`, y metodo redundante de sort; `filteredMenuItems` apunta a `_filterController.sortedFilteredItems`; `clearFilters()` y `setSortBy()` delegan directamente |
| `search_filter_bar.dart` | Convertido de `StatelessWidget` a `StatefulWidget`; `_searchController` con dispose; sincronizacion de texto con estado reactivo; deprecations `withOpacity` → `withValues(alpha:)` |
| `catalog_item_tile.dart` | `ingredients` cambiado de cast manual a `item.ingredientsList` |
| `docs/CODE-REVIEW.md` | Actualizado con estado de correcciones |
| `docs/FILTER-IMPROVEMENT-PLAN.md` | Creado con plan de 3 fases |
| `docs/PROGRESS-TRACKER.md` | Creado con seguimiento de tareas |