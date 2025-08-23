import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/clothing_tile.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/compact_clothing_tile.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/compact_menu_tile.dart';
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
          return const Center(
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
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Determinar el número de columnas basado en el ancho y el modo de vista
            int crossAxisCount;

            if (!controller.isGridView.value) {
              // Modo lista: una sola columna
              crossAxisCount = 1;
            } else {
              // Modo grid: responsive según el ancho
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6; // Escritorio amplio
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 4; // Escritorio estándar
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3; // Tablet
              } else {
                crossAxisCount = 2; // Móvil
              }
            }

            if (controller.isGridView.value) {
              // Vista de grid
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
            } else {
              // Vista de lista con widgets compactos
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredData[index];

                  if (isMenuMode) {
                    final menuItem = item as MenuItemModel;
                    return CompactMenuTile(
                      item: menuItem,
                      selected: controller.detectItemInList(menuItem),
                      onAddCart: controller.selectItemMenu,
                    );
                  } else {
                    final clothingItem = item as ClothingItemModel;
                    return CompactClothingTile(
                      item: clothingItem,
                      selected: controller.detectItemInWardrobe(clothingItem),
                      onAddCart: controller.selectItemWard,
                    );
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}
