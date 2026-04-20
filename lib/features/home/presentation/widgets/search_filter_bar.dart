import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/pu_material.dart';

/// Barra de búsqueda y filtros refactorizada para usar HomeController (Catalog architecture)
/// Usa componentes de pu_material para mejor consistencia y mantenibilidad
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 80;
            final canShowFilters = constraints.maxHeight >= 56;
            return ContainerAtom(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 4 : 12,
                vertical: isCompact ? 2 : 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSearchAndSortRow(controller, isCompact),
                  if (canShowFilters) ...[
                    SizedBox(height: isCompact ? 2 : 6),
                    _buildCategoryFilters(controller, isCompact),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Construye la fila con búsqueda y dropdown de ordenamiento
  Widget _buildSearchAndSortRow(HomeController controller, bool isCompact) {
    return Row(
      children: [
        _buildSearchField(controller, isCompact),
        SizedBox(width: isCompact ? 4 : 12),
        _buildSortDropdown(controller, isCompact),
      ],
    );
  }

  /// Construye el campo de búsqueda usando PUInput
  Widget _buildSearchField(HomeController controller, bool isCompact) {
    return Expanded(
      child: ContainerAtom(
        height: isCompact ? 36 : 48,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        child: PUInput(
          controller: TextEditingController()..text = controller.searchQuery,
          hintText: 'Buscar en el catálogo...',
          onChanged: (val) => controller.updateSearchQuery(val),
          textInputAction: TextInputAction.search,
          compact: isCompact,
          activeBorderColor: PUColors.accentColor,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(HomeController controller, bool isCompact) {
    return ContainerAtom(
      height: isCompact ? 36 : 48,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortByRx.value,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            icon: Icon(
              Icons.sort_rounded,
              color: PUColors.iconColor,
              size: isCompact ? 18 : 22,
            ),
            style: PuTextStyle.bodyMedium,
            items: _buildSortMenuItems(isCompact),
            onChanged: (String? value) {
              if (value != null) {
                controller.setSortBy(value);
              }
            },
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSortMenuItems([bool isCompact = false]) {
    final style = PuTextStyle.bodySmall;
    return [
      DropdownMenuItem(
        value: 'none',
        child: Text('Ordenar', style: style),
      ),
      DropdownMenuItem(
        value: 'name',
        child: Text('Nombre A-Z', style: style),
      ),
      DropdownMenuItem(
        value: 'price_low',
        child: Text('Menor precio', style: style),
      ),
      DropdownMenuItem(
        value: 'price_high',
        child: Text('Mayor precio', style: style),
      ),
    ];
  }

  Widget _buildCategoryFilters(HomeController controller, bool isCompact) {
    return Obx(() => controller.availableCategoriesRx.isNotEmpty
        ? Container(
            height: isCompact ? 32 : 40,
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableCategoriesRx.length,
              itemBuilder: (context, index) {
                final category = controller.availableCategoriesRx[index];
                return _buildCategoryChip(controller, category, isCompact);
              },
            ),
          )
        : const SizedBox());
  }

  Widget _buildCategoryChip(HomeController controller, String category, bool isCompact) {
    return Obx(() {
      final isSelected = controller.selectedCategoryRx.value == category ||
          (controller.selectedCategoryRx.value.isEmpty && category == 'Todos');

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) => controller.selectCategory(selected ? category : ''),
          backgroundColor: Colors.white,
          selectedColor: PUColors.accentColor,
          labelStyle: isSelected 
            ? PuTextStyle.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
            : PuTextStyle.bodySmall,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.05),
            )
          ),
          elevation: isSelected ? 4 : 0,
          shadowColor: PUColors.accentColor.withValues(alpha: 0.4),
        ),
      );
    });
  }
}
