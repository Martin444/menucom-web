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

  /// Construye el grid responsivo usando GridLayoutAtom
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
            children: _buildGridItems(controller, filteredData),
          ),
        );
      },
    );
  }

  /// Calcula la altura de los items basada en las dimensiones de la pantalla
  double _calculateItemHeight(BoxConstraints constraints) {
    double maxWidth = constraints.maxWidth;
    int columns = _getColumnCount(maxWidth);
    double itemWidth = maxWidth / columns;
    return itemWidth * 1.25; // Aspect ratio de 0.8 inverso
  }

  /// Obtiene el número de columnas basado en el ancho disponible
  int _getColumnCount(double maxWidth) {
    if (maxWidth >= 1200) return 5;
    if (maxWidth >= 900) return 4;
    if (maxWidth >= 600) return 3;
    return 2;
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
