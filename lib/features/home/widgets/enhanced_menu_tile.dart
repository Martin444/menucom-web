// ========================================
// ARCHIVO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
// ========================================
// Este archivo contiene una implementación mejorada de MenuTile que nunca se implementó
// en la UI actual. Fue creado durante el refactoring pero no se está usando.
//
// RECOMENDACIÓN: Eliminar este archivo ya que:
// 1. No hay imports de EnhancedMenuTile en ningún archivo
// 2. La funcionalidad está cubierta por menu_tile.dart
// 3. El feature flag useNewArchitecture nunca se implementó
// ========================================

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';
import 'package:pu_material/pu_material.dart';
import '../controllers/home_controller.dart';

/// Versión mejorada de MenuTile que usa la nueva arquitectura
/// Mantiene compatibilidad pero con mejor gestión de estado
class EnhancedMenuTile extends StatelessWidget {
  final MenuItemModel item;
  final bool useNewArchitecture;

  const EnhancedMenuTile({
    super.key,
    required this.item,
    this.useNewArchitecture = false, // Feature flag para migración gradual
  });

  @override
  Widget build(BuildContext context) {
    if (useNewArchitecture) {
      return _buildWithNewArchitecture();
    } else {
      return _buildWithLegacyArchitecture();
    }
  }

  /// Construye el widget usando la nueva arquitectura (HomeController)
  Widget _buildWithNewArchitecture() {
    return GetBuilder<HomeController>(
      tag: 'new',
      builder: (homeController) {
        final itemId = item.id ?? '';
        final quantityInCart = homeController.getCartItemQuantity(itemId);
        final isInCart = quantityInCart > 0;

        return ProductCard.menu(
          title: item.name ?? '',
          price: item.price?.toDouble() ?? 0.0,
          imageUrl: item.photoUrl,
          deliveryTime: item.deliveryTime,
          ingredients: item.ingredients,
          isSelected: isInCart,
          layout: ProductCardLayout.vertical,
          onAddToCart: () => _addToCartWithFeedback(homeController, item),
        );
      },
    );
  }

  /// Construye el widget usando la arquitectura legacy (compatibilidad)
  Widget _buildWithLegacyArchitecture() {
    return ProductCard.menu(
      title: item.name ?? '',
      price: item.price?.toDouble() ?? 0.0,
      imageUrl: item.photoUrl,
      deliveryTime: item.deliveryTime,
      ingredients: item.ingredients,
      isSelected: false, // Se maneja externamente en legacy
      layout: ProductCardLayout.vertical,
      onAddToCart: () {
        // En legacy, el callback se pasa desde el widget padre
        // Este es el comportamiento original
      },
    );
  }

  /// Añade item al carrito con feedback visual mejorado
  void _addToCartWithFeedback(HomeController controller, MenuItemModel item) {
    controller.addToCart(item);

    // Feedback mejorado con información detallada
    Get.snackbar(
      'Agregado al carrito',
      '${item.name} fue agregado al carrito\nTotal: \$${controller.cartTotal.toStringAsFixed(2)}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      // Acción para ir al carrito
      mainButton: TextButton(
        onPressed: () {
          Get.toNamed('/cart'); // Navegar al carrito
        },
        child: const Text(
          'Ver carrito',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Widget factory para facilitar la migración gradual
class MenuTileFactory {
  /// Crea un MenuTile según la configuración del proyecto
  static Widget create({
    required MenuItemModel item,
    bool? selected,
    Function(MenuItemModel)? onAddCart,
  }) {
    // Feature flag: usar nueva arquitectura si está disponible
    final useNewArchitecture = Get.isRegistered<HomeController>(tag: 'new');

    if (useNewArchitecture) {
      return EnhancedMenuTile(
        item: item,
        useNewArchitecture: true,
      );
    } else {
      // Fallback a la implementación original
      return _LegacyMenuTileWrapper(
        item: item,
        selected: selected ?? false,
        onAddCart: onAddCart ?? (_) {},
      );
    }
  }
}

/// Wrapper para mantener compatibilidad exacta con MenuTile original
class _LegacyMenuTileWrapper extends StatelessWidget {
  final MenuItemModel item;
  final bool selected;
  final Function(MenuItemModel) onAddCart;

  const _LegacyMenuTileWrapper({
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard.menu(
      title: item.name ?? '',
      price: item.price?.toDouble() ?? 0.0,
      imageUrl: item.photoUrl,
      deliveryTime: item.deliveryTime,
      ingredients: item.ingredients,
      isSelected: selected,
      layout: ProductCardLayout.vertical,
      onAddToCart: () => onAddCart(item),
    );
  }
}
*/
