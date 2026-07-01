import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class CatalogSelectorOrganism extends StatelessWidget {
  final List<CatalogModel> catalogs;
  final int selectedCatalogIndex;
  final void Function(int index) onCatalogSelected;

  const CatalogSelectorOrganism({
    super.key,
    required this.catalogs,
    required this.selectedCatalogIndex,
    required this.onCatalogSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (catalogs.length <= 1) return const SizedBox.shrink();

    return ContainerAtom(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: catalogs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final catalog = catalogs[index];
            final isSelected = index == selectedCatalogIndex;
            final itemCount = catalog.itemCount;

            return _CatalogChip(
              name: catalog.name ?? 'Catálogo',
              itemCount: itemCount,
              isSelected: isSelected,
              onTap: () => onCatalogSelected(index),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogChip extends StatelessWidget {
  final String name;
  final int itemCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _CatalogChip({
    required this.name,
    required this.itemCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? PUColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? PUColors.primaryColor : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PUColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : PUColors.textColorRich,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (itemCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : PUColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : PUColors.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
