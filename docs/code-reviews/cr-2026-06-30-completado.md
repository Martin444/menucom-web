# Code Review — 2026-06-30

**Estado:** completado
**Revisor:** opencode-agent
**Duración:** aprox. 15 min

---

## Resumen

Review completo post-implementación de Firebase Analytics. Se auditó: bugs, arquitectura, filtros/búsqueda, performance, código muerto y Atomic Design. **0 errores de análisis estático introducidos.** Se encontraron 2 bugs críticos en el flujo de checkout, problemas de arquitectura en HomeController (god object) y OrderController (kitchen sink), y múltiples issues de performance en los widgets de filtro.

---

## Issues Encontrados

### 🐛 Bugs Críticos y Altos

#### CRIT-001: `saveContactToLastOrder()` sin try-catch — checkout roto en error
- **Archivo:** `lib/features/my_cart/getx/order_controller.dart:209`
- **Problema:** `CreateOrderUseCase().call(orders.value)` se ejecuta sin try-catch. Si la API falla, la excepción no se maneja, `isOrderLoading` queda en `true` y la UI se congela permanentemente.
- **Impacto:** 🔴 Alto
- **Solución:** Envolver todo el cuerpo de `saveContactToLastOrder` en try-catch que resetee `isOrderLoading`, `orderStatus`, y muestre error al usuario.

#### CRIT-002: Filtros no se limpian al cambiar de catálogo automáticamente
- **Archivo:** `lib/features/home/controllers/home_controller.dart:161-163`
- **Problema:** El `ever` listener llama `setMenuItems()` sin limpiar filtros previos. Si el catálogo A tiene categoría "Pizza" y el B no, la categoría queda seleccionada en vacío produciendo 0 resultados.
- **Impacto:** 🔴 Alto
- **Solución:** Llamar `_filterController.clearFilters()` antes de `setMenuItems()` en el listener, o hacer que `setMenuItems` limpie el estado por defecto.

#### BUG-001: `rethrow` en `createOrder()` propaga excepción no manejada
- **Archivo:** `lib/features/my_cart/getx/order_controller.dart:166`
- **Problema:** El `rethrow` en el catch escapa hacia `my_cart_page.dart:39` que llama al método como fire-and-forget sin await ni catch.
- **Impacto:** 🟡 Medio
- **Solución:** Eliminar `rethrow`, setear `errorText` y resetear `isLoading` en el catch.

#### BUG-002: `orderCreated` no se null-checkea antes de acceder a `.id`
- **Archivo:** `lib/features/my_cart/getx/order_controller.dart:213`
- **Problema:** `if (orderCreated.id != null)` falla con NPE si `CreateOrderUseCase().call()` retorna null.
- **Impacto:** 🟡 Medio
- **Solución:** `if (orderCreated != null && orderCreated.id != null)`

#### BUG-003: `firstWhere` sin `orElse` usa excepciones como flujo de control
- **Archivo:** `lib/features/home/controllers/catalog_controller.dart:220`
- **Problema:** `_allMenuItems.firstWhere((item) => item.id == itemId)` lanza `StateError` si no encuentra match; el try-catch lo convierte a null. Ineficiente.
- **Impacto:** 🟢 Bajo
- **Solución:** Usar `.firstWhereOrNull()` (GetX incluye esta extensión).

#### BUG-004: Force-unwrap en `order_status_config.dart`
- **Archivo:** `lib/features/my_cart/presentation/widgets/order_status_config.dart:70`
- **Problema:** `configs[status]!` fuerza null assertion; si se agrega un nuevo `OrderStatus`, crashea en runtime.
- **Impacto:** 🟡 Medio
- **Solución:** Devolver un default en vez de forzar unwrap, o usar switch exhaustivo.

---

### 🏗️ Arquitectura

#### ARCH-001: HomeController es un God Object (432 líneas)
- **Archivo:** `lib/features/home/controllers/home_controller.dart`
- **Problema:** Expone TODOS los getters/métodos de CatalogController, FilterController y CartController como pass-through. Además maneja URL parsing, HTML metadata, analytics, y métodos deprecated. Viola SRP.
- **Impacto:** 🔴 Alto
- **Solución:** Limitar HomeController a wiring de listeners. Que los widgets usen `Get.find<FilterController>()` directo en vez de rutear todo por HomeController.

#### ARCH-002: OrderController es un Kitchen Sink (455 líneas)
- **Archivo:** `lib/features/my_cart/getx/order_controller.dart`
- **Problema:** Un solo controller maneja: creación de órdenes, WebSocket, extracción de preferenceId, construcción de URLs de checkout, limpieza de carrito, persistencia, login, y snackbars. Mezcla negocio con UI (`Get.snackbar`).
- **Impacto:** 🔴 Alto
- **Solución:** Extraer `PaymentSocketService`, `MercadoPagoCheckoutService`. Dejar OrderController solo para estado de orden.

#### ARCH-003: Sin paginación — todos los items en memoria
- **Archivo:** `lib/features/home/controllers/catalog_controller.dart:194-197`
- **Problema:** `_flattenMenuItems()` carga TODOS los items. Para catálogos 500+ items hay presión de memoria y lentitud.
- **Impacto:** 🔴 Alto
- **Solución:** Implementar offset/limit en la API o lazy loading con scroll infinito en el grid.

#### ARCH-004: Lógica de negocio en widgets de presentación
- **Archivos:**
  - `lib/features/my_cart/presentation/widgets/confirm_order_actions.dart:29-131` — Google Sign-In, ACCESS_TOKEN, Get.find<> en widget
  - `lib/features/home/presentation/widgets/search_filter_bar.dart:34-37` — TextEditingController.text seteado en build()
  - `lib/features/home/presentation/widgets/filter_summary_widget.dart:15-21` — hasActiveFilters duplicado
  - `lib/features/home/presentation/widgets/catalog_item_tile.dart:34-35` — Get.find<> en onTap
- **Impacto:** 🔴 Alto
- **Solución:** Mover lógica de auth a controller/servicio. Usar listeners en vez de modificar TextEditingController en build.

#### ARCH-005: Dependencias circulares entre features
- **Archivo:** `lib/features/my_cart/getx/order_controller.dart:393-397`
- **Problema:** `OrderController` hace `Get.find<CartController>().clearCart()` desde un callback de WebSocket. Acoplamiento entre features.
- **Impacto:** 🟡 Medio
- **Solución:** Usar un event bus o delegar al coordinator.

#### ARCH-006: `ownerId`/`commerceId` legacy — identidad dual
- **Archivos:** `home_controller.dart:45-53`, `order_controller.dart:29-59`
- **Problema:** Múltiples controladores mantienen ambas variables con cadenas de fallback (`commerce?['id'] ?? owner?['id'] ?? catalog?.id`). Flujo de datos difícil de rastrear.
- **Impacto:** 🟡 Medio
- **Solución:** Migrar completamente a `commerceId` y eliminar `ownerId`.

---

### 🔍 Filtros y Búsqueda

#### FILT-001: `quantity` (stock) no es filtrable
- **Archivo:** `lib/features/home/controllers/filter_controller.dart`
- **Problema:** El modelo tiene `quantity` pero no hay toggle de "En stock" / "Agotado".
- **Impacto:** 🟡 Medio

#### FILT-002: `averageRating` no existe en el modelo
- **Archivo:** `menu_dart_api/lib/by_feature/catalog/models/catalog_model.dart:144`
- **Problema:** AGENTS.md dice que `averageRating` existe pero el campo no está en `CatalogItemModel`.
- **Impacto:** 🟡 Medio

#### FILT-003: `TextNormalizer.normalize()` sin caché — ~1400 llamadas por keystroke
- **Archivo:** `lib/features/home/controllers/filter_controller.dart:283-310`
- **Problema:** Cada búsqueda normaliza name, description, category, y cada tag de cada item. Con 200 items × 5 tags = 1400 llamadas por tecla.
- **Impacto:** 🟡 Medio
- **Solución:** Pre-normalizar al cargar items (`setMenuItems`) y guardar en un campo cached.

---

### ⚡ Performance

#### PERF-001: `GetBuilder<HomeController>` causa rebuilds excesivos en SearchFilterBar
- **Archivo:** `lib/features/home/presentation/widgets/search_filter_bar.dart:31`
- **Problema:** El widget entero se reconstruye con cada cambio en HomeController (incluyendo adiciones al carrito, carga, etc.).
- **Impacto:** 🔴 Alto
- **Solución:** Usar `Obx` sobre Rx específicos en vez de `GetBuilder` global.

#### PERF-002: `TextEditingController.text` seteado dentro de `build()`
- **Archivo:** `lib/features/home/presentation/widgets/search_filter_bar.dart:34-37`
- **Problema:** Modificar el controller dentro de build() puede causar loops infinitos o glitches de cursor.
- **Impacto:** 🔴 Alto

#### PERF-003: `ListView.builder` con `shrinkWrap: true`
- **Archivo:** `lib/features/my_cart/presentation/widgets/products_section.dart:65`
- **Problema:** `shrinkWrap: true` anula el lazy building, todos los children se miden upfront.
- **Impacto:** 🟡 Medio

#### PERF-004: `Obx` redundantes dentro de `GetBuilder`
- **Archivo:** `lib/features/home/presentation/widgets/search_filter_bar.dart:174,221,239,266,305`
- **Problema:** Múltiples `Obx` anidados en un `GetBuilder` que ya los reconstruye.
- **Impacto:** 🟢 Bajo

#### PERF-005: Sort menu items reasignados en cada build
- **Archivo:** `lib/features/home/presentation/widgets/search_filter_bar.dart:198-218`
- **Problema:** Lista estática de DropdownMenuItem recreada en cada build.
- **Impacto:** 🟡 Medio

---

### 🧹 Código Muerto y Deuda Técnica

#### DEAD-001: `RobustNetworkImage` duplicado y sin uso
- **Archivo:** `lib/core/widgets/robust_network_image.dart` (108 líneas)
- **Problema:** Versión legacy sin usar. La canónica es `pu_material/lib/widgets/pu_robust_network_image.dart`.
- **Solución:** Eliminar.

#### DEAD-002: `BusinessGridOrganism` sin uso en catalog
- **Archivo:** `pu_material/lib/organisms/business_grid_organism.dart` (408 líneas)
- **Problema:** Definido pero nunca instanciado en este proyecto.

#### DEBT-001: Método deprecated con implementación completa
- **Archivo:** `lib/features/home/controllers/home_controller.dart:254-270`
- **Problema:** `loadPublicCatalogsByOwnerId` tiene `@deprecated` pero implementación completa con analytics, validación de carrito y metadata HTML.

#### DEBT-002: `print()` en vez de `debugPrint()` (4 ubicaciones)
- **Archivos:** `google_auth_service.dart:54`, `html_metadata_helper.dart:36`, `image_url_service.dart:27`, `robust_network_image.dart:71,104`

#### DEBT-003: `withOpacity` deprecated (2 ubicaciones)
- **Archivos:** `download_status_widget.dart:74`, `category_tile_molecule.dart:151`
- **Solución:** Migrar a `withValues(alpha:)`.

---

### 🧬 Atomic Design

#### ATOM-001: Widgets en `lib/` que deberían estar en `pu_material/`
| Widget | Ubicación actual | Ubicación sugerida |
|---|---|---|
| `CatalogItemTile` | `lib/features/home/presentation/widgets/` | `pu_material/lib/organisms/` |
| `SearchFilterBar` | `lib/features/home/presentation/widgets/` | `pu_material/lib/organisms/` |
| `FilterSummaryWidget` | `lib/features/home/presentation/widgets/` | `pu_material/lib/molecule/` |
| `CatalogSelector` | `lib/features/home/presentation/widgets/` | `pu_material/lib/organisms/` |
| `HeadHome` | `lib/features/home/presentation/widgets/` | `pu_material/lib/organisms/` |
| `ResponsiveItemsGrid` | `lib/features/home/presentation/widgets/` | `pu_material/lib/organisms/` |

#### ATOM-002: MyCart widgets mal ubicados
- **Archivos:** `ProductsSection`, `TotalsSection`, `ConfirmOrderActions` en `lib/features/my_cart/presentation/widgets/`
- **Problema:** Deberían estar en `lib/features/my_cart/ui/organisms/` o en `pu_material/`.

---

### 🔌 Dependencias

| Paquete | Actual | Sugerido |
|---|---|---|
| `get` | 4.6.6 | >=4.7.2 |
| `firebase_core` | ^3.8.1 | ^3.15.2 (ya descargado) |
| `firebase_auth` | ^5.3.4 | ^5.7.0 |
| `shared_preferences` | ^2.2.3 | ^2.5.3 |
| `flutter_svg` | ^2.0.10+1 | ^2.2.0 |
| `svg_flutter` (pu_material) | ^0.0.1 | Eliminar, usar flutter_svg |

---

## Issues Resueltos (desde último review)

| ID | Archivo | Solución |
|---|---|---|
| — | `pubspec.yaml` | `firebase_analytics: ^11.3.6` agregado |
| — | `lib/core/analytics_service.dart` | Singleton AnalyticsService creado |
| — | `lib/core/analytics_events.dart` | Constantes de eventos/parámetros |
| — | `lib/main.dart` | FirebaseAnalyticsObserver + lifecycle observer |
| — | 7 controladores | Eventos analytics integrados (19 tipos de eventos) |
| CRIT-001 | `order_controller.dart:209` | `saveContactToLastOrder` envuelto en try-catch con reset de estado + snackbar |
| BUG-001 | `order_controller.dart:166` | `rethrow` eliminado; ahora setea `errorText` y `isLoading` en catch |
| BUG-002 | `order_controller.dart:213` | Validación de `orderCreated.id != null` (no nullable, se eliminó el check redundante) |
| CRIT-002 | `home_controller.dart:161-163` | `clearFilters()` agregado antes de `setMenuItems()` en el `ever` listener |

---

## Pendientes para Próximo Review

- [x] ~~Fix CRIT-001: try-catch en `saveContactToLastOrder`~~
- [x] ~~Fix CRIT-002: limpiar filtros al cambiar catálogo~~
- [x] ~~Fix BUG-001: `rethrow` en `createOrder()`~~
- [x] ~~Fix BUG-002: null-check en `orderCreated`~~
- [ ] Refactorizar HomeController (reducir god object)
- [ ] Extraer servicios de OrderController (WebSocket, MercadoPago)
- [ ] Implementar paginación/lazy loading
- [ ] Migrar widgets a pu_material (CatalogItemTile, SearchFilterBar, etc.)
- [ ] Eliminar `RobustNetworkImage` legacy
- [ ] Migrar `withOpacity` → `withValues(alpha:)`
- [ ] Migrar `print()` → `debugPrint()`
- [ ] Actualizar dependencias (get, firebase_*, flutter_svg)
- [ ] Agregar filtro de stock (quantity)
- [ ] Agregar campo `averageRating` al modelo
- [ ] Cachear normalización de texto en filtros
- [ ] Eliminar `Obx` redundantes en SearchFilterBar

---

## Checklist de Verificación

- [x] `fvm flutter analyze` ejecutado — 0 errores nuevos, 175 issues preexistentes (warnings/info)
- [x] Bugs críticos documentados (2 altos, 4 medios)
- [x] Issues de arquitectura identificados (6)
- [x] Performance evaluada (5 issues)
- [x] Filtros y búsqueda auditados (3 issues)
- [x] Código muerto y deuda técnica registrada (5 issues)
- [x] Atomic Design y cumplimiento de pu_material verificado (2 issues)
- [x] Dependencias evaluadas (6 paquetes desactualizados)
