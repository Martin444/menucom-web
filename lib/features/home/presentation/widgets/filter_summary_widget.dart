import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class FilterSummaryWidget extends StatelessWidget {
  const FilterSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        int totalItems = controller.filteredMenuItems.length;

        // Solo mostrar si hay filtros activos o elementos para mostrar
        if (totalItems == 0 && controller.searchQuery.isEmpty && (controller.selectedCategory.isEmpty || controller.selectedCategory == 'Todos')) {
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
                    if (controller.searchQuery.isNotEmpty ||
                        (controller.selectedCategory.isNotEmpty && controller.selectedCategory != 'Todos'))
                      const SizedBox(height: 4),
                    if (controller.searchQuery.isNotEmpty ||
                        (controller.selectedCategory.isNotEmpty && controller.selectedCategory != 'Todos'))
                      Row(
                        children: [
                          if (controller.searchQuery.isNotEmpty)
                            Flexible(
                              child: Text(
                                'Búsqueda: "${controller.searchQuery}"',
                                style: PuTextStyle.ingredientsListStyle.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (controller.searchQuery.isNotEmpty &&
                              controller.selectedCategory.isNotEmpty &&
                              controller.selectedCategory != 'Todos')
                            Text(
                              ' • ',
                              style: PuTextStyle.ingredientsListStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          if (controller.selectedCategory.isNotEmpty &&
                              controller.selectedCategory != 'Todos')
                            Flexible(
                              child: Text(
                                'Categoría: ${controller.selectedCategory}',
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
              if (controller.searchQuery.isNotEmpty ||
                  (controller.selectedCategory.isNotEmpty && controller.selectedCategory != 'Todos'))
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
