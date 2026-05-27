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
        final totalItems = controller.filteredMenuItems.length;
        final hasActiveFilters = controller.searchQuery.isNotEmpty ||
            controller.selectedCategories.isNotEmpty ||
            controller.showOnlyAvailable ||
            controller.showOnlyOnSale ||
            controller.showOnlyFeatured ||
            controller.minPrice > 0 ||
            controller.maxPrice < controller.priceUpperBound;

        if (totalItems == 0 && !hasActiveFilters) {
          return const SizedBox();
        }

        final filterBadges = <Widget>[];
        if (controller.searchQuery.isNotEmpty) {
          filterBadges.add(_buildBadge('"${controller.searchQuery}"', Icons.search));
        }
        if (controller.selectedCategories.isNotEmpty) {
          filterBadges.add(_buildBadge(controller.selectedCategories.join(', '), Icons.label));
        }
        if (controller.showOnlyAvailable) {
          filterBadges.add(_buildBadge('Disponibles', Icons.check_circle));
        }
        if (controller.showOnlyOnSale) {
          filterBadges.add(_buildBadge('En oferta', Icons.discount));
        }
        if (controller.showOnlyFeatured) {
          filterBadges.add(_buildBadge('Destacados', Icons.star));
        }
        if (controller.minPrice > 0 || controller.maxPrice < controller.priceUpperBound) {
          filterBadges.add(_buildBadge(
            '\$${controller.minPrice.toStringAsFixed(0)}–\$${controller.maxPrice.toStringAsFixed(0)}',
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
                    if (filterBadges.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filterBadges
                              .map((b) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: b,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasActiveFilters)
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
          Text(
            text,
            style: PuTextStyle.bodySmall.copyWith(
              color: PUColors.accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
