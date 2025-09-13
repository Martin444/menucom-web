// ========================================
// ARCHIVO DE EJEMPLO - NO UTILIZADO EN PRODUCCIÓN
// ========================================
// Este archivo contiene ejemplos de cómo usar la nueva arquitectura con HomeController.
// Fue creado como referencia durante el refactoring pero nunca se implementó en la UI real.
// No hay referencias a estos widgets en ningún archivo del proyecto.
//
// RECOMENDACIÓN: Mantener como documentación o mover a carpeta examples/
// ========================================

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Ejemplo de widget refactorizado para usar el nuevo HomeController
/// Muestra cómo migrar gradualmente de MenuHomeCartController a la nueva arquitectura
class RefactoredMenuItemWidget extends StatelessWidget {
  final String itemId;

  const RefactoredMenuItemWidget({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar el nuevo HomeController en lugar de MenuHomeCartController
    return GetBuilder<HomeController>(
      builder: (controller) {
        final item = controller.getItemById(itemId);

        if (item == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              if (item.photoUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    Text(
                      item.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Ingredientes
                    if (item.ingredients != null && item.ingredients!.isNotEmpty)
                      Text(
                        item.ingredients!.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Precio y controles del carrito
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Precio
                        Text(
                          '\$${(item.price?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        // Controles del carrito
                        _buildCartControls(controller, item.id ?? ''),
                      ],
                    ),

                    // Tiempo de entrega
                    if (item.deliveryTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.deliveryTime} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye los controles del carrito (agregar, incrementar, decrementar)
  Widget _buildCartControls(HomeController controller, String itemId) {
    final quantityInCart = controller.getCartItemQuantity(itemId);

    if (quantityInCart == 0) {
      // Botón para agregar al carrito
      return ElevatedButton.icon(
        onPressed: () {
          final item = controller.getItemById(itemId);
          if (item != null) {
            controller.addToCart(item);

            // Mostrar snackbar de confirmación
            Get.snackbar(
              'Agregado al carrito',
              '${item.name} fue agregado al carrito',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        },
        icon: const Icon(Icons.add_shopping_cart, size: 16),
        label: const Text('Agregar'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      // Controles de cantidad
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón decrementar
            IconButton(
              onPressed: () => controller.decrementCartItem(itemId),
              icon: const Icon(Icons.remove, size: 16),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),

            // Cantidad
            Container(
              constraints: const BoxConstraints(minWidth: 32),
              child: Text(
                quantityInCart.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Botón incrementar
            IconButton(
              onPressed: () => controller.incrementCartItem(itemId),
              icon: const Icon(Icons.add, size: 16),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    }
  }
}

/// Widget de ejemplo para mostrar el carrito usando el nuevo CartController
class RefactoredCartSummaryWidget extends StatelessWidget {
  const RefactoredCartSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return GetBuilder<HomeController>(
      builder: (controller) {
        if (!controller.hasItemsInCart) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Información del carrito
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.cartTotalQuantity} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${controller.cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón ver carrito
                ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla del carrito
                    Get.toNamed('/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Ver carrito'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget de ejemplo para la barra de búsqueda usando FilterController
class RefactoredSearchBarWidget extends StatelessWidget {
  const RefactoredSearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GetBuilder<HomeController>(
        builder: (homeController) => Column(
          children: [
            // Barra de búsqueda
            TextField(
              onChanged: homeController.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: homeController.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => homeController.updateSearchQuery(''),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Filtros de categoría
            if (homeController.availableCategories.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = homeController.availableCategories[index];
                    final isSelected = homeController.selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => homeController.selectCategory(category),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/
