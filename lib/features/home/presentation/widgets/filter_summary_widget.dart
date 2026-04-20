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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PUColors.accentColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: PUColors.accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontramos $totalItems opciones para ti',
                      style: PuTextStyle.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PUColors.textColorRich,
                      ),
                    ),
                    if (controller.searchQuery.isNotEmpty ||
                        (controller.selectedCategory.isNotEmpty && controller.selectedCategory != 'Todos')) ...[
                      const SizedBox(height: 2),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (controller.searchQuery.isNotEmpty)
                              Text(
                                'Buscando "${controller.searchQuery}"',
                                style: PuTextStyle.bodySmall.copyWith(
                                  color: PUColors.textColorMuted,
                                  fontSize: 11,
                                ),
                              ),
                            if (controller.searchQuery.isNotEmpty &&
                                controller.selectedCategory.isNotEmpty &&
                                controller.selectedCategory != 'Todos')
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('•', style: TextStyle(color: PUColors.textColorLight, fontSize: 10)),
                              ),
                            if (controller.selectedCategory.isNotEmpty &&
                                controller.selectedCategory != 'Todos')
                              Text(
                                'Filtro: ${controller.selectedCategory}',
                                style: PuTextStyle.bodySmall.copyWith(
                                  color: PUColors.textColorMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (controller.searchQuery.isNotEmpty ||
                  (controller.selectedCategory.isNotEmpty && controller.selectedCategory != 'Todos'))
                IconButton(
                  onPressed: controller.clearFilters,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: PUColors.textColorLight,
                    size: 20,
                  ),
                  tooltip: 'Limpiar filtros',
                  splashRadius: 20,
                ),
            ],
          ),
        );
      },
    );
  }
}
