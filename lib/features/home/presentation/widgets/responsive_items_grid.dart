import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/clothing_tile.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/menu_tile.dart';
import 'package:pu_material/pu_material.dart';

/// Grid responsivo para mostrar items del menú o ropa
/// Refactorizado para usar atomic design con componentes de pu_material
class ResponsiveItemsGrid extends StatelessWidget {
  const ResponsiveItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        final filteredData = controller.getFilteredItems();

        // Estado vacío usando EmptyStateAtom
        if (filteredData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildResponsiveGrid(controller, filteredData);
      },
    );
  }

  /// Construye el estado vacío usando EmptyStateAtom de pu_material
  Widget _buildEmptyState() {
    return const ContainerAtom(
      height: 400,
      child: EmptyStateAtom(
        title: 'No se encontraron elementos que coincidan con los filtros',
        titleStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Construye el grid responsivo usando GridLayoutAtom optimizado para Sliver
  Widget _buildResponsiveGrid(MenuHomeCartController controller, List<dynamic> filteredData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ContainerAtom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GridLayoutAtom(
            constraints: constraints,
            mainAxisExtent: _calculateItemHeight(constraints),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true, // En SliverFillRemaining necesitamos shrinkWrap
            physics: const NeverScrollableScrollPhysics(), // Sin scroll propio
            children: _buildGridItems(controller, filteredData),
          ),
        );
      },
    );
  }

  /// Calcula la altura de los items basada en las dimensiones de la pantalla
  double _calculateItemHeight(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final columns = _getColumnCount(maxWidth);

    // Calcular ancho disponible por item (considerando spacing)
    final totalSpacing = (columns - 1) * 20; // crossAxisSpacing
    final horizontalPadding = 24; // padding del container
    final availableWidth = maxWidth - totalSpacing - horizontalPadding;
    final itemWidth = availableWidth / columns;

    // Altura adaptativa basada en breakpoints
    if (maxWidth >= 1200) {
      return itemWidth * 1.3; // Desktop: más alto para mejor proporción
    } else if (maxWidth >= 700) {
      return itemWidth * 1.25; // Tablet: proporción equilibrada
    } else {
      return itemWidth * 1.4; // Mobile: más alto para mejor legibilidad
    }
  }

  /// Obtiene el número de columnas basado en el ancho disponible
  /// Mantiene compatibilidad con desktop (6 columnas para pantallas grandes)
  int _getColumnCount(double maxWidth) {
    if (maxWidth >= 1400) return 6; // Pantallas muy grandes: 6 columnas
    if (maxWidth >= 1200) return 5; // Desktop grande: 5 columnas
    if (maxWidth >= 900) return 4; // Desktop: 4 columnas
    if (maxWidth >= 700) return 3; // Tablet grande: 3 columnas
    if (maxWidth >= 500) return 2; // Tablet/Mobile grande: 2 columnas
    return 2; // Mobile: mínimo 2 columnas
  }

  /// Construye los items del grid según el tipo (menú o ropa)
  List<Widget> _buildGridItems(MenuHomeCartController controller, List<dynamic> filteredData) {
    return filteredData.map((item) {
      if (item is MenuItemModel) {
        final isAdded = controller.detectItemInList(item);
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              '/product-detail',
              arguments: {
                'name': item.name ?? '',
                'brand': item.deliveryTime != null ? 'Entrega: ${item.deliveryTime}' : '',
                'description': item.ingredients?.join(', ') ?? '',
                'photoUrl': item.photoUrl ?? '',
                'price': item.price?.toString() ?? '',
                'sizes': [],
                'color': '',
                'onAddCart': controller.selectItemMenu,
                'item': item,
                'isAdded': isAdded,
              },
            );
          },
          child: MenuTile(
            item: item,
            selected: isAdded,
            onAddCart: controller.selectItemMenu,
          ),
        );
      } else if (item is ClothingItemModel) {
        final isAdded = controller.detectItemInWardrobe(item);
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              '/product-detail',
              arguments: {
                'name': item.name ?? '',
                'brand': item.brand ?? '',
                'description': item.name ?? '',
                'photoUrl': item.photoURL ?? '',
                'price': item.price?.toString() ?? '',
                'sizes': item.sizes ?? [],
                'color': item.color ?? '',
                'onAddCart': controller.selectItemWard,
                'item': item,
                'isAdded': isAdded,
              },
            );
          },
          child: ClothingTile(
            item: item,
            selected: isAdded,
            onAddCart: controller.selectItemWard,
          ),
        );
      } else {
        return const SizedBox.shrink(); // fallback para tipos desconocidos
      }
    }).toList();
  }
}
