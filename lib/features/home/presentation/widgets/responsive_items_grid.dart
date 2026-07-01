import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/filter_controller.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/features/home/controllers/catalog_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/catalog_item_tile.dart';
import 'package:pu_material/pu_material.dart';

/// Grid responsivo para mostrar items del catalogo con lazy loading
class ResponsiveItemsGrid extends StatelessWidget {
  final bool isSliver;

  const ResponsiveItemsGrid({
    super.key,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(
      builder: (filterCtrl) {
        final items = filterCtrl.displayedItems;
        final hasMore = filterCtrl.hasMoreItems;
        final isLoading = Get.find<CatalogController>().isLoading;

        if (items.isEmpty && !isLoading) {
          final emptyContent = _buildEmptyState();
          return isSliver ? SliverToBoxAdapter(child: emptyContent) : emptyContent;
        }

        final grid = _buildResponsiveGrid(filterCtrl, items);

        if (!hasMore) {
          return grid;
        }

        final loadMore = _buildLoadMoreButton(filterCtrl);

        if (isSliver) {
          return SliverList(
            delegate: SliverChildListDelegate([
              grid,
              SliverToBoxAdapter(child: loadMore),
            ]),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [grid, loadMore],
        );
      },
    );
  }

  Widget _buildLoadMoreButton(FilterController controller) {
    final remaining = controller.sortedFilteredItems.length - controller.displayLimit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () => controller.incrementDisplayLimit(),
          icon: const Icon(Icons.expand_more, size: 20),
          label: Text('Mostrar más ($remaining restantes)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: PUColors.primaryColor,
            side: BorderSide(color: PUColors.primaryColor.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }

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

  Widget _buildResponsiveGrid(FilterController filterCtrl, List<CatalogItemModel> filteredData) {
    if (isSliver) {
      return SliverLayoutBuilder(
        builder: (context, sliverConstraints) {
          final constraints = BoxConstraints(maxWidth: sliverConstraints.crossAxisExtent);
          final mainAxisExtent = _calculateItemHeight(constraints);
          final children = _buildGridItems(filteredData);

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverGridLayoutAtom(
              constraints: constraints,
              mainAxisExtent: mainAxisExtent,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: children,
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mainAxisExtent = _calculateItemHeight(constraints);
        final children = _buildGridItems(filteredData);

        return ContainerAtom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GridLayoutAtom(
            constraints: constraints,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: children,
          ),
        );
      },
    );
  }

  double _calculateItemHeight(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final columns = _getColumnCount(maxWidth);

    final totalSpacing = (columns - 1) * 24;
    const horizontalPadding = 32.0;
    final availableWidth = (maxWidth - totalSpacing - horizontalPadding).clamp(0.0, double.infinity);
    final itemWidth = availableWidth / columns;

    double height;
    if (maxWidth >= 1200) {
      height = itemWidth * 1.3;
    } else if (maxWidth >= 700) {
      height = itemWidth * 1.25;
    } else {
      height = itemWidth * 1.4;
    }
    
    return height.clamp(260.0, double.infinity);
  }

  int _getColumnCount(double maxWidth) {
    if (maxWidth >= 1400) return 5;
    if (maxWidth >= 1100) return 4;
    if (maxWidth >= 800) return 3;
    if (maxWidth >= 500) return 2;
    return 2;
  }

  List<Widget> _buildGridItems(List<CatalogItemModel> filteredData) {
    final cartCtrl = Get.find<CartController>();
    final catalogCtrl = Get.find<CatalogController>();

    return filteredData.map((item) {
      final isAdded = cartCtrl.containsItem(item.id);

      return CatalogItemTile(
        item: item,
        selected: isAdded,
        catalogType: catalogCtrl.catalogResponse?.catalogType ?? 'wardrobe',
        onAddCart: (i) => cartCtrl.toggleItem(i),
      );
    }).toList();
  }
}
