import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/pu_material.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final currentQuery = controller.searchQuery;
        if (_searchController.text != currentQuery) {
          _searchController.text = currentQuery;
          _searchController.selection = TextSelection.collapsed(offset: currentQuery.length);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 80;
            final isWide = constraints.maxWidth >= 768;
            return ContainerAtom(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: isCompact ? 6 : 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchAndSortRow(controller, isCompact),
                  SizedBox(height: isCompact ? 6 : 8),
                  _buildCategoryFilters(controller, isCompact),
                  if (isWide) ...[
                    const SizedBox(height: 4),
                    _buildToggleChips(controller),
                    const SizedBox(height: 4),
                    _buildPriceSlider(controller),
                  ] else ...[
                    if (_showAdvanced) ...[
                      const SizedBox(height: 4),
                      _buildToggleChips(controller),
                      const SizedBox(height: 4),
                      _buildPriceSlider(controller),
                    ],
                    const SizedBox(height: 2),
                    _buildAdvancedToggle(controller),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdvancedToggle(HomeController controller) {
    final hasAdvancedFilters = controller.showOnlyAvailable ||
        controller.showOnlyOnSale ||
        controller.showOnlyFeatured ||
        controller.minPrice > 0 ||
        controller.maxPrice < controller.priceUpperBound;

    return GestureDetector(
      onTap: () => setState(() => _showAdvanced = !_showAdvanced),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              _showAdvanced ? Icons.expand_less : Icons.tune_rounded,
              size: 16,
              color: PUColors.textColorMuted,
            ),
            const SizedBox(width: 4),
            Text(
              _showAdvanced ? 'Ocultar filtros' : 'Filtros avanzados',
              style: PuTextStyle.bodySmall.copyWith(color: PUColors.textColorMuted),
            ),
            if (hasAdvancedFilters)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: PUColors.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Activos',
                  style: PuTextStyle.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortRow(HomeController controller, bool isCompact) {
    return Row(
      children: [
        _buildSearchField(controller, isCompact),
        SizedBox(width: isCompact ? 8 : 12),
        _buildSortDropdown(controller, isCompact),
      ],
    );
  }

  Widget _buildSearchField(HomeController controller, bool isCompact) {
    return Expanded(
      child: ContainerAtom(
        height: isCompact ? 44 : 48,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 22 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        child: PUInput(
          controller: _searchController,
          hintText: 'Buscar en el catálogo...',
          onChanged: (val) => controller.updateSearchQuery(val),
          textInputAction: TextInputAction.search,
          compact: false,
          activeBorderColor: PUColors.accentColor,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(HomeController controller, bool isCompact) {
    return ContainerAtom(
      height: isCompact ? 44 : 48,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(isCompact ? 22 : 24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortByRx.value,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            icon: Icon(
              Icons.sort_rounded,
              color: PUColors.iconColor,
              size: isCompact ? 20 : 22,
            ),
            style: PuTextStyle.bodyMedium.copyWith(fontSize: isCompact ? 13 : null),
            items: _buildSortMenuItems(),
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

  List<DropdownMenuItem<String>> _buildSortMenuItems() {
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
        ? SizedBox(
            height: isCompact ? 32 : 40,
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
      final isSelected = controller.selectedCategoriesRx.contains(category);

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) => controller.toggleCategory(category),
          backgroundColor: Colors.white,
          selectedColor: PUColors.accentColor,
          labelStyle: isSelected
              ? PuTextStyle.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
              : PuTextStyle.bodySmall,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          elevation: isSelected ? 4 : 0,
          shadowColor: PUColors.accentColor.withValues(alpha: 0.4),
        ),
      );
    });
  }

  Widget _buildToggleChips(HomeController controller) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          FilterChip(
            label: Text('Disponibles', style: PuTextStyle.bodySmall),
            selected: controller.showOnlyAvailableRx.value,
            onSelected: (_) => controller.toggleAvailableOnly(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
          FilterChip(
            label: Text('En oferta', style: PuTextStyle.bodySmall),
            selected: controller.showOnlyOnSaleRx.value,
            onSelected: (_) => controller.toggleOnSale(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
          FilterChip(
            label: Text('Destacados', style: PuTextStyle.bodySmall),
            selected: controller.showOnlyFeaturedRx.value,
            onSelected: (_) => controller.toggleFeatured(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
        ],
      ),
    ));
  }

  Widget _buildPriceSlider(HomeController controller) {
    return Obx(() {
      final upperBound = controller.priceUpperBoundRx.value;
      if (upperBound <= 0) return const SizedBox();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rango de precio',
                  style: PuTextStyle.bodySmall.copyWith(color: PUColors.textColorMuted),
                ),
                Text(
                  '\$${controller.minPriceRx.value.toStringAsFixed(0)} – \$${controller.maxPriceRx.value.toStringAsFixed(0)}',
                  style: PuTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PUColors.textColorRich,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(controller.minPriceRx.value, controller.maxPriceRx.value),
              min: 0,
              max: upperBound,
              divisions: (upperBound / 100).round().clamp(1, 50),
              activeColor: PUColors.accentColor,
              labels: RangeLabels(
                '\$${controller.minPriceRx.value.toStringAsFixed(0)}',
                '\$${controller.maxPriceRx.value.toStringAsFixed(0)}',
              ),
              onChanged: (values) => controller.setPriceRange(values.start, values.end),
            ),
          ],
        ),
      );
    });
  }
}