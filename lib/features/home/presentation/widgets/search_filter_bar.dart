import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Barra de búsqueda y toggle de vista
              Row(
                children: [
                  // Campo de búsqueda
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: controller.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          hintStyle: PuTextStyle.ingredientsListStyle,
                          prefixIcon: Icon(
                            Icons.search,
                            color: PUColors.iconColorBlack.withValues(alpha: 0.6),
                          ),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: PUColors.iconColorBlack.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () => controller.updateSearchQuery(''),
                                )
                              : const SizedBox()),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Dropdown de ordenamiento
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.sortBy.value,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            icon: Icon(
                              Icons.sort,
                              color: PUColors.iconColorBlack,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'none',
                                child: Text('Ordenar por'),
                              ),
                              DropdownMenuItem(
                                value: 'name',
                                child: Text('Nombre A-Z'),
                              ),
                              DropdownMenuItem(
                                value: 'price_low',
                                child: Text('Precio: menor a mayor'),
                              ),
                              DropdownMenuItem(
                                value: 'price_high',
                                child: Text('Precio: mayor a menor'),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                controller.setSortBy(value);
                              }
                            },
                          ),
                        )),
                  ),

                  const SizedBox(width: 12),

                  // Toggle vista grid/lista
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: controller.toggleViewMode,
                      icon: Obx(() => Icon(
                            controller.isGridView.value ? Icons.list : Icons.grid_view,
                            color: PUColors.iconColorBlack,
                          )),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Chips de categorías
              Obx(() => controller.availableCategories.isNotEmpty
                  ? SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.availableCategories.length,
                        itemBuilder: (context, index) {
                          final category = controller.availableCategories[index];
                          final isSelected = controller.selectedCategory.value == category ||
                              (controller.selectedCategory.value.isEmpty && category == 'Todos');

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: PuTextStyle.ingredientsListStyle.copyWith(
                                  color: isSelected ? Colors.white : PUColors.iconColorBlack,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                controller.selectCategory(selected ? category : '');
                              },
                              backgroundColor: Colors.white,
                              selectedColor: PUColors.primaryColor,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color:
                                    isSelected ? PUColors.primaryColor : PUColors.iconColorBlack.withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
        );
      },
    );
  }
}
