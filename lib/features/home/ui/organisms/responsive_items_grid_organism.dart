import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/ui/organisms/catalog_item_tile_organism.dart';
import 'package:pu_material/pu_material.dart';

class ResponsiveItemsGridOrganism extends StatelessWidget {
  final List<CatalogItemModel> items;
  final bool isLoadingMore;
  final String catalogType;
  final void Function(CatalogItemModel item) onItemTap;
  final bool Function(String itemId) isItemAdded;
  final void Function(CatalogItemModel item) onAddToCart;
  final bool isSliver;

  const ResponsiveItemsGridOrganism({
    super.key,
    required this.items,
    required this.isLoadingMore,
    required this.catalogType,
    required this.onItemTap,
    required this.isItemAdded,
    required this.onAddToCart,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final emptyContent = _buildEmptyState();
      return isSliver ? SliverToBoxAdapter(child: emptyContent) : emptyContent;
    }

    final grid = _buildResponsiveGrid(items);

    if (!isLoadingMore) {
      return grid;
    }

    final loading = _buildLoadingIndicator();

    if (isSliver) {
      return SliverList(
        delegate: SliverChildListDelegate([
          grid,
          SliverToBoxAdapter(child: loading),
        ]),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [grid, loading],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: PUColors.primaryColor,
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

  Widget _buildResponsiveGrid(List<CatalogItemModel> filteredData) {
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
    return filteredData.map((item) {
      return CatalogItemTileOrganism(
        item: item,
        selected: isItemAdded(item.id),
        catalogType: catalogType,
        isAdded: isItemAdded(item.id),
        onAddCart: () => onAddToCart(item),
        onTap: (i) => onItemTap(i),
      );
    }).toList();
  }
}
