// ========================================
// ARCHIVO NO UTILIZADO - CANDIDATO PARA ELIMINACIÓN
// ========================================
// Este archivo contiene una versión compacta de ClothingTile que nunca se implementó.
// No hay referencias a CompactClothingTile en ningún archivo del proyecto.
// La funcionalidad está cubierta por clothing_tile.dart que es el que se usa actualmente.
//
// RECOMENDACIÓN: Eliminar este archivo
// ========================================

/*
  final ClothingItemModel item;
  final bool selected;
  final Function(ClothingItemModel) onAddCart;

  const CompactClothingTile({
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
*/
