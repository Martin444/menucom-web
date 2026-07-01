import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/filter_controller.dart';
import 'package:pu_material/pu_material.dart';

/// Sidebar de filtros vertical para layout desktop (web).
/// Se muestra fijo en el lado izquierdo en pantallas >= 900px.
class DesktopFilterSidebar extends StatefulWidget {
  const DesktopFilterSidebar({super.key});

  @override
  State<DesktopFilterSidebar> createState() => _DesktopFilterSidebarState();
}

class _DesktopFilterSidebarState extends State<DesktopFilterSidebar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    final filterCtrl = Get.find<FilterController>();
    ever(filterCtrl.searchQueryRx, (String query) {
      if (_searchController.text != query) {
        _searchController.text = query;
        _searchController.selection = TextSelection.collapsed(offset: query.length);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(
      builder: (controller) {
        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(controller),
                      const SizedBox(height: 20),
                      _buildSortSection(controller),
                      const SizedBox(height: 20),
                      _buildCategorySection(controller),
                      const SizedBox(height: 20),
                      _buildToggleSection(controller),
                      const SizedBox(height: 20),
                      _buildPriceSection(controller),
                    ],
                  ),
                ),
              ),
              _buildFilterSummary(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(FilterController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PUColors.primaryBackground,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 18, color: PUColors.accentColor),
          const SizedBox(width: 8),
          Text(
            'Filtros',
            style: PuTextStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: PUColors.textColorRich,
            ),
          ),
          const Spacer(),
          if (controller.hasActiveFilters)
            GestureDetector(
              onTap: controller.clearFilters,
              child: Text(
                'Limpiar',
                style: PuTextStyle.bodySmall.copyWith(
                  color: PUColors.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField(FilterController controller) {
    return ContainerAtom(
      height: 44,
      padding: EdgeInsets.zero,
      backgroundColor: PUColors.primaryBackground,
      borderRadius: BorderRadius.circular(12),
      child: PUInput(
        controller: _searchController,
        hintText: 'Buscar...',
        onChanged: (val) => controller.updateSearchQuery(val),
        textInputAction: TextInputAction.search,
        compact: true,
        activeBorderColor: PUColors.accentColor,
      ),
    );
  }

  Widget _buildSortSection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ordenar por'),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PUColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.sortByRx.value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              style: PuTextStyle.bodySmall,
              items: [
                DropdownMenuItem(value: 'none', child: Text('Predeterminado', style: PuTextStyle.bodySmall)),
                DropdownMenuItem(value: 'name', child: Text('Nombre A-Z', style: PuTextStyle.bodySmall)),
                DropdownMenuItem(value: 'price_low', child: Text('Menor precio', style: PuTextStyle.bodySmall)),
                DropdownMenuItem(value: 'price_high', child: Text('Mayor precio', style: PuTextStyle.bodySmall)),
              ],
              onChanged: (value) {
                if (value != null) controller.setSortBy(value);
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCategorySection(FilterController controller) {
    return Obx(() {
      if (controller.availableCategoriesRx.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Categorías'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: controller.availableCategoriesRx.map((category) {
              final isSelected = controller.selectedCategoriesRx.contains(category);
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => controller.toggleCategory(category),
                backgroundColor: Colors.white,
                selectedColor: PUColors.accentColor,
                labelStyle: isSelected
                    ? PuTextStyle.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                    : PuTextStyle.bodySmall.copyWith(color: PUColors.textColorRich),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                elevation: isSelected ? 3 : 0,
                shadowColor: PUColors.accentColor.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildToggleSection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filtros'),
        const SizedBox(height: 8),
        Obx(() => Column(
          children: [
            _buildToggleTile(
              label: 'Disponibles',
              icon: Icons.check_circle_outline,
              value: controller.showOnlyAvailableRx.value,
              onChanged: (_) => controller.toggleAvailableOnly(),
            ),
            _buildToggleTile(
              label: 'En oferta',
              icon: Icons.local_offer_outlined,
              value: controller.showOnlyOnSaleRx.value,
              onChanged: (_) => controller.toggleOnSale(),
            ),
            _buildToggleTile(
              label: 'Destacados',
              icon: Icons.star_outline,
              value: controller.showOnlyFeaturedRx.value,
              onChanged: (_) => controller.toggleFeatured(),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildToggleTile({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: value ? PUColors.accentColor.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: value ? PUColors.accentColor : PUColors.textColorMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: PuTextStyle.bodySmall.copyWith(
                      color: value ? PUColors.accentColor : PUColors.textColorRich,
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 18,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return Colors.white;
                      return Colors.grey[500];
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return PUColors.accentColor;
                      return Colors.grey[300];
                    }),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(FilterController controller) {
    return Obx(() {
      final upperBound = controller.priceUpperBoundRx.value;
      if (upperBound <= 0) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rango de precio'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${controller.minPriceRx.value.toStringAsFixed(0)}',
                style: PuTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600, color: PUColors.textColorRich),
              ),
              Text(
                '\$${controller.maxPriceRx.value.toStringAsFixed(0)}',
                style: PuTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600, color: PUColors.textColorRich),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(controller.minPriceRx.value, controller.maxPriceRx.value),
            min: 0,
            max: upperBound,
            divisions: (upperBound / 100).round().clamp(1, 50),
            activeColor: PUColors.accentColor,
            inactiveColor: PUColors.accentColor.withValues(alpha: 0.15),
            labels: RangeLabels(
              '\$${controller.minPriceRx.value.toStringAsFixed(0)}',
              '\$${controller.maxPriceRx.value.toStringAsFixed(0)}',
            ),
            onChanged: (values) => controller.setPriceRange(values.start, values.end),
          ),
        ],
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: PuTextStyle.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        color: PUColors.textColorMuted,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildFilterSummary(FilterController controller) {
    return GetBuilder<FilterController>(
      builder: (ctrl) {
        final totalItems = ctrl.sortedFilteredItems.length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: PUColors.primaryBackground,
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: PUColors.accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$totalItems productos',
                  style: PuTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PUColors.textColorRich,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
