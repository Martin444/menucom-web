import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/catalog_item_tile.dart';
import 'package:pu_material/pu_material.dart';

/// Grid responsivo para mostrar items del catálogo
class ResponsiveItemsGrid extends StatelessWidget {
  const ResponsiveItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final filteredData = controller.filteredMenuItems;

        // Estado vacío usando EmptyStateAtom
        if (filteredData.isEmpty && !controller.isLoadHomeItems) {
          return _buildEmptyState();
        }

        return _buildResponsiveGrid(controller, filteredData);
      },
    );
  }

  /// Construye el estado vacío usando EmptyStateAtom de pu_material
  Widget _buildEmptyState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: EmptyStateAtom(
          title: 'No se encontraron elementos que coincidan con los filtros',
          titleStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  /// Construye el grid responsivo usando GridLayoutAtom
  Widget _buildResponsiveGrid(HomeController controller, List<CatalogItemModel> filteredData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ContainerAtom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GridLayoutAtom(
            constraints: constraints,
            mainAxisExtent: _calculateItemHeight(constraints),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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

    final totalSpacing = (columns - 1) * 20;
    final horizontalPadding = 24;
    final availableWidth = maxWidth - totalSpacing - horizontalPadding;
    final itemWidth = availableWidth / columns;

    if (maxWidth >= 1200) {
      return itemWidth * 1.35;
    } else if (maxWidth >= 700) {
      return itemWidth * 1.3;
    } else {
      return itemWidth * 1.5;
    }
  }

  int _getColumnCount(double maxWidth) {
    if (maxWidth >= 1400) return 6;
    if (maxWidth >= 1200) return 5;
    if (maxWidth >= 900) return 4;
    if (maxWidth >= 700) return 3;
    if (maxWidth >= 500) return 2;
    return 2;
  }

  /// Construye los items del grid según el tipo de catálogo
  List<Widget> _buildGridItems(HomeController controller, List<CatalogItemModel> filteredData) {
    return filteredData.map((item) {
      final isAdded = controller.detectItemInList(item);
      
      return GestureDetector(
        onTap: () {
          Get.toNamed(
            '/product-detail',
            arguments: {
              'item': item,
              'isAdded': isAdded,
              'onAddCart': (CatalogItemModel i) => controller.selectItem(i),
              'name': item.name,
              'description': item.description,
              'photoUrl': item.photoURL,
              'price': item.price.toString(),
            },
          );
        },
        child: CatalogItemTile(
          item: item,
          selected: isAdded,
          catalogType: controller.catalog?.catalogType ?? 'wardrobe',
          onAddCart: (i) => controller.selectItem(i),
        ),
      );
    }).toList();
  }
}
