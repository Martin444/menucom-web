import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class FilterSummaryWidget extends StatelessWidget {
  const FilterSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        // Contar totales
        int totalMenuItems = 0;
        int totalWardrobeItems = 0;

        for (var menu in controller.filteredMenu) {
          if (menu.items != null) {
            totalMenuItems += menu.items!.where((item) {
              return controller.searchQuery.value.isEmpty ||
                  item.name!.toLowerCase().contains(controller.searchQuery.value.toLowerCase()) ||
                  (item.ingredients != null &&
                      item.ingredients!.any((ingredient) =>
                          ingredient.toLowerCase().contains(controller.searchQuery.value.toLowerCase())));
            }).length;
          }
        }

        for (var wardrobe in controller.filteredWardList) {
          if (wardrobe.items != null) {
            totalWardrobeItems += wardrobe.items!.where((item) {
              return controller.searchQuery.value.isEmpty ||
                  item.name!.toLowerCase().contains(controller.searchQuery.value.toLowerCase()) ||
                  (item.brand != null &&
                      item.brand!.toLowerCase().contains(controller.searchQuery.value.toLowerCase())) ||
                  (item.color != null &&
                      item.color!.toLowerCase().contains(controller.searchQuery.value.toLowerCase()));
            }).length;
          }
        }

        int totalItems = totalMenuItems + totalWardrobeItems;

        // Solo mostrar si hay filtros activos o elementos para mostrar
        if (totalItems == 0 && controller.searchQuery.value.isEmpty && controller.selectedCategory.value.isEmpty) {
          return const SizedBox();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PUColors.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono informativo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PUColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: PUColors.primaryColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Información de filtros
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mostrando $totalItems productos',
                      style: PuTextStyle.nameProductStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.searchQuery.value.isNotEmpty ||
                        (controller.selectedCategory.value.isNotEmpty && controller.selectedCategory.value != 'Todos'))
                      const SizedBox(height: 4),
                    if (controller.searchQuery.value.isNotEmpty ||
                        (controller.selectedCategory.value.isNotEmpty && controller.selectedCategory.value != 'Todos'))
                      Row(
                        children: [
                          if (controller.searchQuery.value.isNotEmpty)
                            Flexible(
                              child: Text(
                                'Búsqueda: "${controller.searchQuery.value}"',
                                style: PuTextStyle.ingredientsListStyle.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (controller.searchQuery.value.isNotEmpty &&
                              controller.selectedCategory.value.isNotEmpty &&
                              controller.selectedCategory.value != 'Todos')
                            Text(
                              ' • ',
                              style: PuTextStyle.ingredientsListStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          if (controller.selectedCategory.value.isNotEmpty &&
                              controller.selectedCategory.value != 'Todos')
                            Flexible(
                              child: Text(
                                'Categoría: ${controller.selectedCategory.value}',
                                style: PuTextStyle.ingredientsListStyle.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              // Botón limpiar filtros
              if (controller.searchQuery.value.isNotEmpty ||
                  (controller.selectedCategory.value.isNotEmpty && controller.selectedCategory.value != 'Todos'))
                IconButton(
                  onPressed: controller.clearFilters,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  tooltip: 'Limpiar filtros',
                ),
            ],
          ),
        );
      },
    );
  }
}
