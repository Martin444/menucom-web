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
        height: isCompact ? 32 : 44,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: isCompact ? 2 : 4,
            offset: const Offset(0, 1),
          ),
        ],
        child: PUInput(
          controller: TextEditingController()..text = controller.searchQuery,
          hintText: 'Buscar productos...',
          onChanged: (val) => controller.updateSearchQuery(val),
          textInputAction: TextInputAction.search,
          compact: isCompact,
        ),
      ),
    );
  }

  /// Construye el dropdown de ordenamiento con estilo mejorado
  Widget _buildSortDropdown(HomeController controller, bool isCompact) {
    return ContainerAtom(
      height: isCompact ? 32 : 44,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(isCompact ? 12 : 24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: isCompact ? 2 : 4,
          offset: const Offset(0, 1),
        ),
      ],
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortByRx.value,
            borderRadius: BorderRadius.circular(isCompact ? 12 : 24),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 16),
            icon: IconAtom(
              icon: Icons.sort,
              color: PUColors.iconColorBlack,
              size: isCompact ? 18 : 24,
            ),
            style: TextStyle(fontSize: isCompact ? 13 : 16),
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

  /// Construye los items del menú de ordenamiento
  List<DropdownMenuItem<String>> _buildSortMenuItems([bool isCompact = false]) {
    final style = TextStyle(fontSize: isCompact ? 13 : 16);
    return [
      DropdownMenuItem(
        value: 'none',
        child: Text('Ordenar por', style: style),
      ),
      DropdownMenuItem(
        value: 'name',
        child: Text('Nombre A-Z', style: style),
      ),
      DropdownMenuItem(
        value: 'price_low',
        child: Text('Precio: menor a mayor', style: style),
      ),
      DropdownMenuItem(
        value: 'price_high',
        child: Text('Precio: mayor a menor', style: style),
      ),
    ];
  }

  /// Construye los filtros de categorías con scroll horizontal mejorado
  Widget _buildCategoryFilters(HomeController controller, bool isCompact) {
    return Obx(() => controller.availableCategoriesRx.isNotEmpty
        ? SizedBox(
            height: isCompact ? 24 : 32,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 2),
              physics: const ClampingScrollPhysics(),
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

  /// Construye un chip de categoría individual
  Widget _buildCategoryChip(HomeController controller, String category, bool isCompact) {
    return Obx(() {
      final isSelected = controller.selectedCategoryRx.value == category ||
          (controller.selectedCategoryRx.value.isEmpty && category == 'Todos');

      return ContainerAtom(
        margin: EdgeInsets.only(right: isCompact ? 4 : 8),
        child: FilterChip(
          label: Text(
            category,
            style: PuTextStyle.ingredientsListStyle.copyWith(
              fontSize: isCompact ? 11 : 14,
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
            color: isSelected ? PUColors.primaryColor : PUColors.iconColorBlack.withValues(alpha: 0.3),
          ),
          visualDensity: isCompact ? VisualDensity.compact : VisualDensity.standard,
          materialTapTargetSize: isCompact ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
        ),
      );
    });
  }
}
