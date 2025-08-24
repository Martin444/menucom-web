import 'package:flutter/material.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';
import 'package:pu_material/pu_material.dart';

class MenuTile extends StatelessWidget {
  final MenuItemModel item;
  final bool selected;
  final Function(MenuItemModel) onAddCart;

  const MenuTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard.menu(
      title: item.name ?? '',
      price: item.price?.toDouble() ?? 0.0,
      imageUrl: item.photoUrl,
      deliveryTime: item.deliveryTime,
      ingredients: item.ingredients,
      isSelected: selected,
      layout: ProductCardLayout.vertical,
      onAddToCart: () => onAddCart(item),
    );
  }
}
