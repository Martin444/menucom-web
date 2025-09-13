# Refactoring Guide: Clean Architecture Migration

## Resumen de Cambios

Este proyecto ha sido refactorizado para implementar Clean Architecture utilizando los módulos existentes de `menu_dart_api`. El objetivo es separar responsabilidades, mejorar la mantenibilidad y optimizar el performance.

## Arquitectura Actual vs Nueva

### Antes (Monolítica)
```
MenuHomeCartController (517 líneas)
├── Gestión de menús
├── Lógica de carrito
├── Filtros y búsquedas
├── Estado de UI
├── Llamadas a API
└── Cálculos de totales
```

### Después (Clean Architecture)
```
HomeController (Coordinador)
├── MenuController → menu_dart_api (GetMenuUseCase)
├── FilterController → Debounced search + categories
├── CartController → Cart management + totals
└── Shared utilities (Debouncer, TextNormalizer)
```

## Controladores Especializados

### 1. MenuController
**Responsabilidad**: Gestión de datos del menú
- Carga menús usando `GetMenuUseCase` de menu_dart_api
- Maneja estado de loading y errores
- Proporciona acceso a `MenuResponse`, `OwnerModel`, `MenuModel[]`

```dart
final menuController = Get.find<MenuController>();
await menuController.loadMenu(ownerId);
final items = menuController.allMenuItems;
final owner = menuController.owner;
```

### 2. FilterController
**Responsabilidad**: Filtros, búsquedas y categorías
- Búsqueda con debouncing (300ms)
- Filtrado por categorías (ingredientes)
- Normalización de texto para búsquedas
- Rangos de precio

```dart
final filterController = Get.find<FilterController>();
filterController.updateSearchQuery("pizza"); // Con debouncing
filterController.selectCategory("Vegetariano");
final filtered = filterController.filteredItems;
```

### 3. CartController
**Responsabilidad**: Gestión del carrito
- Agregar/remover items
- Cálculo de subtotales, impuestos, totales
- Persistencia local del carrito
- Conversión a `OrderItemModel[]` para checkout

```dart
final cartController = Get.find<CartController>();
cartController.addItem(menuItem, quantity: 2);
cartController.incrementItem(itemId);
final total = cartController.total;
final orderItems = cartController.toOrderItems();
```

### 4. HomeController (Coordinador)
**Responsabilidad**: Coordinación y compatibilidad con UI existente
- Integra los 3 controladores especializados
- Mantiene compatibilidad con widgets existentes
- Expone getters unificados para la UI

```dart
final homeController = Get.find<HomeController>();
// Acceso unificado a toda la funcionalidad
final items = homeController.filteredMenuItems;
final cartTotal = homeController.cartTotal;
homeController.addToCart(item);
```

## Migración Gradual

### Paso 1: Coexistencia (ACTUAL)
- ✅ Controladores antiguos y nuevos coexisten
- ✅ UI existente sigue funcionando
- ✅ Bindings actualizados con ambas opciones

### Paso 2: Migración por Widget
Migrar widgets uno por uno usando el nuevo `HomeController`:

```dart
// Antes
class OldWidget extends StatelessWidget {
  Widget build(context) {
    final controller = Get.find<MenuHomeCartController>();
    return Text(controller.listMenuItems.length.toString());
  }
}

// Después  
class NewWidget extends StatelessWidget {
  Widget build(context) {
    final controller = Get.find<HomeController>(tag: 'new');
    return Text(controller.filteredMenuItems.length.toString());
  }
}
```

### Paso 3: Validación
- Probar cada widget migrado
- Validar funcionalidad de carrito
- Verificar performance de búsquedas

### Paso 4: Reemplazo Final
- Reemplazar `MenuHomeCartController` con `HomeController`
- Remover código legacy
- Limpiar imports no utilizados

## Beneficios de la Nueva Arquitectura

### 1. Separation of Concerns
- Cada controlador tiene una responsabilidad específica
- Fácil testeo unitario por funcionalidad
- Reducción de acoplamiento

### 2. Performance Optimizations
- **Debounced Search**: Evita llamadas excesivas durante escritura
- **Reactive Updates**: Solo actualiza UI cuando cambian datos relevantes
- **Lazy Loading**: Controladores se cargan solo cuando se necesitan

### 3. Mantenibilidad
- Archivos más pequeños y enfocados
- Lógica de negocio claramente separada
- Reutilización de código

### 4. Reutilización de menu_dart_api
- No duplica lógica ya existente
- Usa modelos y use cases probados
- Mantiene consistencia con el API

## Archivos Clave

### Nuevos Controladores
- `lib/features/home/controllers/menu_controller.dart`
- `lib/features/home/controllers/filter_controller.dart` 
- `lib/features/home/controllers/cart_controller.dart`
- `lib/features/home/controllers/home_controller.dart`

### Utilidades
- `lib/shared/utils/debouncer.dart`
- `lib/shared/utils/text_normalizer.dart`

### Bindings
- `lib/features/home/getx/menu_binding.dart` (actualizado)

### Ejemplos
- `lib/features/home/widgets/refactored_widgets_example.dart`

## Testing

### Controladores Especializados
```dart
// Ejemplo de test para FilterController
test('should filter items by search query', () {
  final controller = FilterController();
  final items = [/* test items */];
  
  controller.setMenuItems(items);
  controller.updateSearchQuery('pizza');
  
  expect(controller.filteredItems.length, 2);
});
```

### Integración
```dart
// Test de integración HomeController
test('should coordinate menu loading and filtering', () async {
  final homeController = HomeController();
  
  await homeController.loadMenu('ownerId');
  homeController.updateSearchQuery('pasta');
  
  expect(homeController.filteredMenuItems.isNotEmpty, true);
});
```

## Próximos Pasos

1. **Migrar widgets críticos** (carrito, búsqueda, lista de items)
2. **Implementar tests unitarios** para cada controlador
3. **Optimizar performance** con más granularidad reactiva
4. **Documentar patterns** para futuros desarrollos
5. **Considerar state management más avanzado** (Riverpod) si el proyecto crece

## Compatibilidad

Durante la migración, ambos sistemas coexisten:
- `Get.find<MenuHomeCartController>()` → Sistema antiguo
- `Get.find<HomeController>(tag: 'new')` → Sistema nuevo

Esto permite migración sin downtime y rollback en caso de problemas.