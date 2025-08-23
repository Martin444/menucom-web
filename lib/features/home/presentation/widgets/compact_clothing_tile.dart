import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

class CompactClothingTile extends StatelessWidget {
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: PuStyleContainers.borderAllContainer,
      child: Row(
        children: [
          // Imagen compacta
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PuRobustNetworkImage(
              imageUrl: item.photoURL ?? '',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              clearCacheOnError: true,
            ),
          ),

          const SizedBox(width: 12),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del producto
                PUOverflowTextDetector(
                  message: item.name!,
                  children: [
                    Text(
                      item.name!,
                      style: PuTextStyle.nameProductStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Marca y color
                Row(
                  children: [
                    if (item.brand != null && item.brand!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.brand!,
                          style: PuTextStyle.ingredientsListStyle.copyWith(
                            color: Colors.orange[700],
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (item.brand != null && item.color != null) const SizedBox(width: 4),
                    if (item.color != null && item.color!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.color!,
                          style: PuTextStyle.ingredientsListStyle.copyWith(
                            color: Colors.purple[700],
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Tallas (si existen)
                if (item.sizes != null && item.sizes!.isNotEmpty)
                  PUOverflowTextDetector(
                    message: 'Tallas: ${item.sizes!.join(', ')}',
                    children: [
                      Text(
                        'Tallas: ${item.sizes!.join(', ')}',
                        style: PuTextStyle.ingredientsListStyle.copyWith(
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                // Precio, cantidad y botón
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.price!.toString().convertToCorrency(),
                          style: PuTextStyle.nameProductStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                        if (item.quantity != null && item.quantity! > 0)
                          Text(
                            'Stock: ${item.quantity}',
                            style: PuTextStyle.ingredientsListStyle.copyWith(
                              fontSize: 10,
                              color: item.quantity! > 5 ? Colors.green : Colors.orange,
                            ),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => onAddCart(item),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected ? Colors.green : Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          selected ? PUIcons.iconCheck : PUIcons.iconCart,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
