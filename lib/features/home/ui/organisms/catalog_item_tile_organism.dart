import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class CatalogItemTileOrganism extends StatelessWidget {
  final CatalogItemModel item;
  final bool selected;
  final String catalogType;
  final bool isAdded;
  final VoidCallback onAddCart;
  final ValueChanged<CatalogItemModel> onTap;

  const CatalogItemTileOrganism({
    super.key,
    required this.item,
    required this.selected,
    required this.catalogType,
    required this.isAdded,
    required this.onAddCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMenu = catalogType == 'restaurant' || catalogType == 'menu';

    return InteractiveAtom(
      hoverScale: 1.05,
      duration: const Duration(milliseconds: 300),
      borderRadius: 16,
      backgroundColor: Colors.transparent,
      semanticsLabel: 'Ver detalle de ${item.name}',
      onTap: () => onTap(item),
      child: isMenu
          ? ProductCard.menu(
              title: item.name,
              price: item.price,
              imageUrl: item.photoURL,
              deliveryTime: item.attributes?['deliveryTime'] as int? ?? 30,
              ingredients: item.ingredientsList.isNotEmpty ? item.ingredientsList : null,
              isSelected: selected,
              layout: ProductCardLayout.vertical,
              onAddToCart: onAddCart,
            )
          : ProductCard.clothing(
              title: item.name,
              price: item.price,
              imageUrl: item.photoURL,
              brand: item.attributes?['brand'] as String?,
              color: item.attributes?['color'] as String?,
              sizes: (item.attributes?['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
              quantity: item.quantity,
              isSelected: selected,
              layout: ProductCardLayout.vertical,
              onAddToCart: onAddCart,
            ),
    );
  }
}
