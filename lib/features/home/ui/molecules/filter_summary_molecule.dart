import 'package:flutter/material.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class FilterSummaryMolecule extends StatelessWidget {
  final int totalItems;
  final String searchQuery;
  final List<String> selectedCategories;
  final bool showOnlyAvailable;
  final bool showOnlyOnSale;
  final bool showOnlyFeatured;
  final double minPrice;
  final double maxPrice;
  final double priceUpperBound;
  final VoidCallback onClearFilters;

  const FilterSummaryMolecule({
    super.key,
    required this.totalItems,
    required this.searchQuery,
    required this.selectedCategories,
    required this.showOnlyAvailable,
    required this.showOnlyOnSale,
    required this.showOnlyFeatured,
    required this.minPrice,
    required this.maxPrice,
    required this.priceUpperBound,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategories.isNotEmpty ||
      showOnlyAvailable ||
      showOnlyOnSale ||
      showOnlyFeatured ||
      minPrice > 0 ||
      maxPrice < priceUpperBound;

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0 && !hasActiveFilters) {
      return const SizedBox();
    }

    final filterBadges = <Widget>[];
    if (searchQuery.isNotEmpty) {
      filterBadges.add(_buildBadge('"$searchQuery"', Icons.search));
    }
    if (selectedCategories.isNotEmpty) {
      filterBadges.add(_buildBadge(selectedCategories.join(', '), Icons.label));
    }
    if (showOnlyAvailable) {
      filterBadges.add(_buildBadge('Disponibles', Icons.check_circle));
    }
    if (showOnlyOnSale) {
      filterBadges.add(_buildBadge('En oferta', Icons.discount));
    }
    if (showOnlyFeatured) {
      filterBadges.add(_buildBadge('Destacados', Icons.star));
    }
    if (minPrice > 0 || maxPrice < priceUpperBound) {
      filterBadges.add(_buildBadge(
        '\$${minPrice.toStringAsFixed(0)}-\$${maxPrice.toStringAsFixed(0)}',
        Icons.attach_money,
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: PUColors.accentColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: PUColors.accentColor, size: 18),
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
                if (filterBadges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterBadges
                          .map((b) => Padding(padding: const EdgeInsets.only(right: 4), child: b))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasActiveFilters)
            IconButton(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh_rounded, color: PUColors.textColorLight, size: 20),
              tooltip: 'Limpiar filtros',
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PUColors.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: PUColors.accentColor),
          const SizedBox(width: 4),
          Text(text, style: PuTextStyle.bodySmall.copyWith(color: PUColors.accentColor, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
