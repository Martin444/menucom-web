import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/pu_material.dart';

/// CatalogItemTile - Widget unificado para mostrar items del catálogo
/// Determina automáticamente si debe mostrarse como un item de restaurante o de tienda (clothing)
class CatalogItemTile extends StatelessWidget {
  final CatalogItemModel item;
  final bool selected;
  final String catalogType;
  final Function(CatalogItemModel) onAddCart;

  const CatalogItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.catalogType,
    required this.onAddCart,
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
      onTap: () {
        final isAdded = Get.find<HomeController>().detectItemInList(item);
        Get.toNamed(
          '/product-detail',
          arguments: {
            'item': item,
            'isAdded': isAdded,
            'onAddCart': (CatalogItemModel i) => Get.find<HomeController>().selectItem(i),
            'name': item.name,
            'description': item.description,
            'photoUrl': item.photoURL,
            'price': item.price.toString(),
          },
        );
      },
      child: isMenu
          ? ProductCard.menu(
              title: item.name,
              price: item.price,
              imageUrl: item.photoURL,
              deliveryTime: item.attributes?['deliveryTime'] as int? ?? 30,
              ingredients: item.attributes?['ingredients'] != null
                  ? (item.attributes?['ingredients'] as String).split(',').map((e) => e.trim()).toList()
                  : null,
              isSelected: selected,
              layout: ProductCardLayout.vertical,
              onAddToCart: () => onAddCart(item),
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
              onAddToCart: () => onAddCart(item),
            ),
    );
  }
}
