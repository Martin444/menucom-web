import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class ClothingTile extends StatelessWidget {
  final ClothingItemModel item;
  final bool selected;
  final Function(ClothingItemModel) onAddCart;

  const ClothingTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard.clothing(
      title: item.name ?? '',
      price: item.price?.toDouble() ?? 0.0,
      imageUrl: item.photoURL,
      brand: item.brand,
      color: item.color,
      sizes: item.sizes,
      quantity: item.quantity,
      isSelected: selected,
      layout: ProductCardLayout.vertical,
      onAddToCart: () => onAddCart(item),
    );
  }
}
