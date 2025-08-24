import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/clothing_tile.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/menu_tile.dart';

class ResponsiveItemsGrid extends StatelessWidget {
  const ResponsiveItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        final isMenuMode = controller.isMenuMode;
        final filteredData = controller.getFilteredItems();

        // Si no hay elementos filtrados
        if (filteredData.isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron elementos que coincidan con los filtros',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: 2 mobile, 3 tablet, hasta 5 desktop
            double maxWidth = constraints.maxWidth;
            int columns = 2;
            if (maxWidth >= 1200) {
              columns = 5;
            } else if (maxWidth >= 900) {
              columns = 4;
            } else if (maxWidth >= 600) {
              columns = 3;
            }
            double spacing = 20;
            // double totalSpacing = spacing * (columns - 1); // No se usa
            // double itemWidth = (maxWidth - totalSpacing) / columns; // No se usa
            double aspectRatio = 0.8;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                if (isMenuMode) {
                  final menuItem = item as MenuItemModel;
                  return MenuTile(
                    item: menuItem,
                    selected: controller.detectItemInList(menuItem),
                    onAddCart: controller.selectItemMenu,
                  );
                } else {
                  final clothingItem = item as ClothingItemModel;
                  return ClothingTile(
                    item: clothingItem,
                    selected: controller.detectItemInWardrobe(clothingItem),
                    onAddCart: controller.selectItemWard,
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
