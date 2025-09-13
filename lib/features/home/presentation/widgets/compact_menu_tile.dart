// ========================================
// ARCHIVO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
// ========================================
// Este archivo contiene una versión compacta de MenuTile que nunca se implementó.
// No hay referencias a CompactMenuTile en ningún archivo del proyecto.
// La funcionalidad está cubierta por menu_tile.dart que es el que se usa actualmente.
//
// RECOMENDACIÓN: Eliminar este archivo
// ========================================

/*
import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class CompactMenuTile extends StatelessWidget {
  final MenuItemModel item;
  final bool selected;
  final Function(MenuItemModel) onAddCart;

  const CompactMenuTile({
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
      layout: ProductCardLayout.horizontal,
      onAddToCart: () => onAddCart(item),
    );
  }
}
*/
