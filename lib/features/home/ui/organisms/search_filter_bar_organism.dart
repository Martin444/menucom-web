import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class SearchFilterBarOrganism extends StatelessWidget {
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

  final void Function(String) onSearchChanged;
  final void Function(String) onSortChanged;
  final void Function(String) onCategoryToggled;
  final VoidCallback onAvailableToggled;
  final VoidCallback onSaleToggled;
  final VoidCallback onFeaturedToggled;
  final void Function(double min, double max) onPriceRangeChanged;

  const SearchFilterBarOrganism({
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
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryToggled,
    required this.onAvailableToggled,
    required this.onSaleToggled,
    required this.onFeaturedToggled,
    required this.onPriceRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SearchFilterBarBody(
      searchQuery: searchQuery,
      sortBy: sortBy,
      availableCategories: availableCategories,
      selectedCategories: selectedCategories,
      showOnlyAvailable: showOnlyAvailable,
      showOnlyOnSale: showOnlyOnSale,
      showOnlyFeatured: showOnlyFeatured,
      minPrice: minPrice,
      maxPrice: maxPrice,
      priceUpperBound: priceUpperBound,
      onSearchChanged: onSearchChanged,
      onSortChanged: onSortChanged,
      onCategoryToggled: onCategoryToggled,
      onAvailableToggled: onAvailableToggled,
      onSaleToggled: onSaleToggled,
      onFeaturedToggled: onFeaturedToggled,
      onPriceRangeChanged: onPriceRangeChanged,
    );
  }
}

class _SearchFilterBarBody extends StatefulWidget {
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

  final void Function(String) onSearchChanged;
  final void Function(String) onSortChanged;
  final void Function(String) onCategoryToggled;
  final VoidCallback onAvailableToggled;
  final VoidCallback onSaleToggled;
  final VoidCallback onFeaturedToggled;
  final void Function(double min, double max) onPriceRangeChanged;

  const _SearchFilterBarBody({
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
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryToggled,
    required this.onAvailableToggled,
    required this.onSaleToggled,
    required this.onFeaturedToggled,
    required this.onPriceRangeChanged,
  });

  @override
  State<_SearchFilterBarBody> createState() => _SearchFilterBarBodyState();
}

class _SearchFilterBarBodyState extends State<_SearchFilterBarBody> {
  late TextEditingController _searchController;
  bool _showAdvanced = false;

  late final List<DropdownMenuItem<String>> _sortMenuItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _sortMenuItems = _buildSortMenuItems();
  }

  @override
  void didUpdateWidget(covariant _SearchFilterBarBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.collapsed(offset: widget.searchQuery.length);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildSearchAndSortRow(isCompact),
              SizedBox(height: isCompact ? 6 : 8),
              _buildCategoryFilters(isCompact),
              if (isWide) ...[
                const SizedBox(height: 4),
                _buildToggleChips(),
                const SizedBox(height: 4),
                _buildPriceSlider(),
              ] else ...[
                if (_showAdvanced) ...[
                  const SizedBox(height: 4),
                  _buildToggleChips(),
                  const SizedBox(height: 4),
                  _buildPriceSlider(),
                ],
                const SizedBox(height: 2),
                _buildAdvancedToggle(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedToggle() {
    final hasAdvancedFilters = widget.showOnlyAvailable ||
        widget.showOnlyOnSale ||
        widget.showOnlyFeatured ||
        widget.minPrice > 0 ||
        widget.maxPrice < widget.priceUpperBound;

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

  Widget _buildSearchAndSortRow(bool isCompact) {
    return Row(
      children: [
        _buildSearchField(isCompact),
        SizedBox(width: isCompact ? 8 : 12),
        _buildSortDropdown(isCompact),
      ],
    );
  }

  Widget _buildSearchField(bool isCompact) {
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
          onChanged: (val) => widget.onSearchChanged(val),
          textInputAction: TextInputAction.search,
          compact: false,
          activeBorderColor: PUColors.accentColor,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(bool isCompact) {
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.sortBy,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          icon: Icon(
            Icons.sort_rounded,
            color: PUColors.iconColor,
            size: isCompact ? 20 : 22,
          ),
          style: PuTextStyle.bodyMedium.copyWith(fontSize: isCompact ? 13 : null),
          items: _sortMenuItems,
          onChanged: (String? value) {
            if (value != null) {
              widget.onSortChanged(value);
            }
          },
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

  Widget _buildCategoryFilters(bool isCompact) {
    final categories = widget.availableCategories;
    if (categories.isEmpty) return const SizedBox();

    return SizedBox(
      height: isCompact ? 32 : 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryChip(category, isCompact);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isCompact) {
    final isSelected = widget.selectedCategories.contains(category);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) => widget.onCategoryToggled(category),
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
  }

  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          FilterChip(
            label: Text('Disponibles', style: PuTextStyle.bodySmall),
            selected: widget.showOnlyAvailable,
            onSelected: (_) => widget.onAvailableToggled(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
          FilterChip(
            label: Text('En oferta', style: PuTextStyle.bodySmall),
            selected: widget.showOnlyOnSale,
            onSelected: (_) => widget.onSaleToggled(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
          FilterChip(
            label: Text('Destacados', style: PuTextStyle.bodySmall),
            selected: widget.showOnlyFeatured,
            onSelected: (_) => widget.onFeaturedToggled(),
            backgroundColor: Colors.white,
            selectedColor: PUColors.accentColor.withValues(alpha: 0.15),
            checkmarkColor: PUColors.accentColor,
            side: BorderSide(color: PUColors.accentColor.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSlider() {
    final upperBound = widget.priceUpperBound;
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
                '\$${widget.minPrice.toStringAsFixed(0)} \u2013 \$${widget.maxPrice.toStringAsFixed(0)}',
                style: PuTextStyle.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PUColors.textColorRich,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(widget.minPrice, widget.maxPrice),
            min: 0,
            max: upperBound,
            divisions: (upperBound / 100).round().clamp(1, 50),
            activeColor: PUColors.accentColor,
            labels: RangeLabels(
              '\$${widget.minPrice.toStringAsFixed(0)}',
              '\$${widget.maxPrice.toStringAsFixed(0)}',
            ),
            onChanged: (values) => widget.onPriceRangeChanged(values.start, values.end),
          ),
        ],
      ),
    );
  }
}
