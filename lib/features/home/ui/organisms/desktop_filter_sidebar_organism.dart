import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class DesktopFilterSidebarOrganism extends StatefulWidget {
  final String searchQuery;
  final String sortBy;
  final List<String> availableCategories;
  final List<String> selectedCategories;
  final bool showOnlyAvailable;
  final bool showOnlyOnSale;
  final bool showOnlyFeatured;
  final double minPrice;
  final double maxPrice;
  final double priceUpperBound;
  final int totalFilteredItems;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onCategoryToggled;
  final VoidCallback onAvailableToggled;
  final VoidCallback onSaleToggled;
  final VoidCallback onFeaturedToggled;
  final void Function(double min, double max) onPriceRangeChanged;
  final VoidCallback onClearFilters;

  const DesktopFilterSidebarOrganism({
    super.key,
    required this.searchQuery,
    required this.sortBy,
    required this.availableCategories,
    required this.selectedCategories,
    required this.showOnlyAvailable,
    required this.showOnlyOnSale,
    required this.showOnlyFeatured,
    required this.minPrice,
    required this.maxPrice,
    required this.priceUpperBound,
    required this.totalFilteredItems,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryToggled,
    required this.onAvailableToggled,
    required this.onSaleToggled,
    required this.onFeaturedToggled,
    required this.onPriceRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<DesktopFilterSidebarOrganism> createState() =>
      _DesktopFilterSidebarOrganismState();
}

class _DesktopFilterSidebarOrganismState
    extends State<DesktopFilterSidebarOrganism> {
  late TextEditingController _searchController;

  bool get _hasActiveFilters =>
      widget.searchQuery.isNotEmpty ||
      widget.sortBy != 'none' ||
      widget.selectedCategories.isNotEmpty ||
      widget.showOnlyAvailable ||
      widget.showOnlyOnSale ||
      widget.showOnlyFeatured ||
      widget.minPrice > 0 ||
      widget.maxPrice < widget.priceUpperBound;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant DesktopFilterSidebarOrganism oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
      _searchController.selection =
          TextSelection.collapsed(offset: widget.searchQuery.length);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 20),
                  _buildSortSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                  const SizedBox(height: 20),
                  _buildToggleSection(),
                  const SizedBox(height: 20),
                  _buildPriceSection(),
                ],
              ),
            ),
          ),
          _buildFilterSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          const Icon(
              Icons.tune_rounded, size: 18, color: PUColors.accentColor),
          const SizedBox(width: 8),
          Text(
            'Filtros',
            style: PuTextStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: PUColors.textColorRich,
            ),
          ),
          const Spacer(),
          if (_hasActiveFilters)
            GestureDetector(
              onTap: widget.onClearFilters,
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

  Widget _buildSearchField() {
    return ContainerAtom(
      height: 44,
      padding: EdgeInsets.zero,
      backgroundColor: PUColors.primaryBackground,
      borderRadius: BorderRadius.circular(12),
      child: PUInput(
        controller: _searchController,
        hintText: 'Buscar...',
        onChanged: widget.onSearchChanged,
        textInputAction: TextInputAction.search,
        compact: true,
        activeBorderColor: PUColors.accentColor,
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ordenar por'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PUColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.sortBy,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              style: PuTextStyle.bodySmall,
              items: [
                DropdownMenuItem(
                    value: 'none',
                    child: Text('Predeterminado',
                        style: PuTextStyle.bodySmall)),
                DropdownMenuItem(
                    value: 'name',
                    child:
                        Text('Nombre A-Z', style: PuTextStyle.bodySmall)),
                DropdownMenuItem(
                    value: 'price_low',
                    child:
                        Text('Menor precio', style: PuTextStyle.bodySmall)),
                DropdownMenuItem(
                    value: 'price_high',
                    child:
                        Text('Mayor precio', style: PuTextStyle.bodySmall)),
              ],
              onChanged: (value) {
                if (value != null) widget.onSortChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    if (widget.availableCategories.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Categorías'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.availableCategories.map((category) {
            final isSelected =
                widget.selectedCategories.contains(category);
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => widget.onCategoryToggled(category),
              backgroundColor: Colors.white,
              selectedColor: PUColors.accentColor,
              labelStyle: isSelected
                  ? PuTextStyle.bodySmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)
                  : PuTextStyle.bodySmall.copyWith(
                      color: PUColors.textColorRich),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              elevation: isSelected ? 3 : 0,
              shadowColor:
                  PUColors.accentColor.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filtros'),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildToggleTile(
              label: 'Disponibles',
              icon: Icons.check_circle_outline,
              value: widget.showOnlyAvailable,
              onChanged: (_) => widget.onAvailableToggled(),
            ),
            _buildToggleTile(
              label: 'En oferta',
              icon: Icons.local_offer_outlined,
              value: widget.showOnlyOnSale,
              onChanged: (_) => widget.onSaleToggled(),
            ),
            _buildToggleTile(
              label: 'Destacados',
              icon: Icons.star_outline,
              value: widget.showOnlyFeatured,
              onChanged: (_) => widget.onFeaturedToggled(),
            ),
          ],
        ),
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
        color: value
            ? PUColors.accentColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: value
                      ? PUColors.accentColor
                      : PUColors.textColorMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: PuTextStyle.bodySmall.copyWith(
                      color: value
                          ? PUColors.accentColor
                          : PUColors.textColorRich,
                      fontWeight:
                          value ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 18,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    thumbColor:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.grey[500];
                    }),
                    trackColor:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return PUColors.accentColor;
                      }
                      return Colors.grey[300];
                    }),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildPriceSection() {
    final upperBound = widget.priceUpperBound;
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
              '\$${widget.minPrice.toStringAsFixed(0)}',
              style: PuTextStyle.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PUColors.textColorRich),
            ),
            Text(
              '\$${widget.maxPrice.toStringAsFixed(0)}',
              style: PuTextStyle.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PUColors.textColorRich),
            ),
          ],
        ),
        RangeSlider(
          values:
              RangeValues(widget.minPrice, widget.maxPrice),
          min: 0,
          max: upperBound,
          divisions: (upperBound / 100).round().clamp(1, 50),
          activeColor: PUColors.accentColor,
          inactiveColor:
              PUColors.accentColor.withValues(alpha: 0.15),
          labels: RangeLabels(
            '\$${widget.minPrice.toStringAsFixed(0)}',
            '\$${widget.maxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (values) =>
              widget.onPriceRangeChanged(values.start, values.end),
        ),
      ],
    );
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

  Widget _buildFilterSummary() {
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
          const Icon(Icons.auto_awesome_rounded,
              size: 14, color: PUColors.accentColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${widget.totalFilteredItems} productos',
              style: PuTextStyle.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: PUColors.textColorRich,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
