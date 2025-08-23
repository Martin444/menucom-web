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
            // Determinar el ancho máximo del item para mantener consistencia
            double maxCrossAxisExtent;

            if (!controller.isGridView.value) {
              // Modo lista: ancho completo
              maxCrossAxisExtent = constraints.maxWidth;
            } else {
              // Modo grid: ancho fijo para mantener consistencia
              if (constraints.maxWidth > 1200) {
                maxCrossAxisExtent = 200; // Items más pequeños en pantallas grandes
              } else if (constraints.maxWidth > 900) {
                maxCrossAxisExtent = 220; // Tamaño medio
              } else if (constraints.maxWidth > 600) {
                maxCrossAxisExtent = 250; // Tamaño para tablet
              } else {
                maxCrossAxisExtent = 160; // Tamaño para móvil
              }
            }

            // Calcular aproximadamente cuántos items cabrán para estimar altura
            int estimatedColumns =
                !controller.isGridView.value ? 1 : (constraints.maxWidth / (maxCrossAxisExtent + 16)).floor();
            double itemHeight = controller.isGridView.value ? 280 : 160;
            int rows = (filteredData.length / estimatedColumns).ceil();
            double totalHeight = (rows * itemHeight) + 32; // Incluye padding

            if (controller.isGridView.value) {
              // Vista de grid con altura fija usando maxCrossAxisExtent
              return SizedBox(
                height: totalHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent,
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
                ),
              );
            } else {
              // Vista de lista con altura fija
              return SizedBox(
                height: totalHeight,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
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
                ),
              );
            }
          },
        );
      },
    );
  }
}

// Versión con Slivers para CustomScrollView
class ResponsiveItemsSliver extends StatelessWidget {
  const ResponsiveItemsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        final isMenuMode = controller.isMenuMode;
        final filteredData = controller.getFilteredItems();

        // Si no hay elementos filtrados
        if (filteredData.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
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
            ),
          );
        }

        // Determinar el ancho máximo del item en lugar de número fijo de columnas
        final screenWidth = MediaQuery.of(context).size.width;
        double maxCrossAxisExtent;

        if (!controller.isGridView.value) {
          // Modo lista: ancho completo
          maxCrossAxisExtent = double.infinity;
        } else {
          // Modo grid: ancho fijo para mantener consistencia
          if (screenWidth > 1200) {
            maxCrossAxisExtent = 230; // Items más pequeños en pantallas grandes
          } else if (screenWidth > 900) {
            maxCrossAxisExtent = 220; // Tamaño medio
          } else if (screenWidth > 600) {
            maxCrossAxisExtent = 250; // Tamaño para tablet
          } else {
            maxCrossAxisExtent = 290; // Tamaño para móvil
          }
        }

        if (controller.isGridView.value) {
          // Vista de grid con SliverGrid usando ancho máximo fijo
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                childCount: filteredData.length,
              ),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
            ),
          );
        } else {
          // Vista de lista con SliverList
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index % 2 == 1) {
                    // Separador
                    return const SizedBox(height: 12);
                  }

                  final itemIndex = index ~/ 2;
                  if (itemIndex >= filteredData.length) return null;

                  final item = filteredData[itemIndex];

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
                childCount: filteredData.length * 2 - 1, // Items + separadores
              ),
            ),
          );
        }
      },
    );
  }
}
