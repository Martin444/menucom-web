import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/catalog_item_tile.dart';
import 'package:pu_material/pu_material.dart';

/// Grid responsivo para mostrar items del catálogo
class ResponsiveItemsGrid extends StatelessWidget {
  /// Si debe retornar un Sliver en lugar de un Widget normal
  final bool isSliver;

  const ResponsiveItemsGrid({
    super.key,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final filteredData = controller.filteredMenuItems;

        // Estado vacío
        if (filteredData.isEmpty && !controller.isLoadHomeItems) {
          final emptyContent = _buildEmptyState();
          return isSliver ? SliverToBoxAdapter(child: emptyContent) : emptyContent;
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

  /// Construye el grid responsivo usando GridLayoutAtom o SliverGridLayoutAtom
  Widget _buildResponsiveGrid(HomeController controller, List<CatalogItemModel> filteredData) {
    if (isSliver) {
      return SliverLayoutBuilder(
        builder: (context, sliverConstraints) {
          // Convertir SliverConstraints a BoxConstraints para reutilizar la lógica de cálculo
          final constraints = BoxConstraints(maxWidth: sliverConstraints.crossAxisExtent);
          final mainAxisExtent = _calculateItemHeight(constraints);
          final children = _buildGridItems(controller, filteredData);

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            sliver: SliverGridLayoutAtom(
              constraints: constraints,
              mainAxisExtent: mainAxisExtent,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: children,
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mainAxisExtent = _calculateItemHeight(constraints);
        final children = _buildGridItems(controller, filteredData);

        return ContainerAtom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GridLayoutAtom(
            constraints: constraints,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: children,
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
    const horizontalPadding = 24.0;
    final availableWidth = (maxWidth - totalSpacing - horizontalPadding).clamp(0.0, double.infinity);
    final itemWidth = availableWidth / columns;

    double height;
    if (maxWidth >= 1200) {
      height = itemWidth * 1.35;
    } else if (maxWidth >= 700) {
      height = itemWidth * 1.3;
    } else {
      height = itemWidth * 1.5;
    }
    
    // Garantizar una altura mínima para evitar errores de layout
    return height.clamp(250.0, double.infinity);
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
      
      return CatalogItemTile(
        item: item,
        selected: isAdded,
        catalogType: controller.catalog?.catalogType ?? 'wardrobe',
        onAddCart: (i) => controller.selectItem(i),
      );
    }).toList();
  }
}
