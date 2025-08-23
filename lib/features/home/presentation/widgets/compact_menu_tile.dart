import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

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

  String formatDeliveryTime(int deliveryTime) {
    if (deliveryTime < 60) {
      return '${deliveryTime}min';
    } else if (deliveryTime < 1440) {
      int hours = deliveryTime ~/ 60;
      int minutes = deliveryTime % 60;
      return '${hours}h ${minutes}min';
    } else {
      int days = deliveryTime ~/ 1440;
      return '${days}d';
    }
  }

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
              imageUrl: item.photoUrl ?? '',
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

                // Tiempo de entrega
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDeliveryTime(item.deliveryTime!),
                    style: PuTextStyle.ingredientsListStyle.copyWith(
                      color: Colors.blue[700],
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Ingredientes (si existen)
                if (item.ingredients != null && item.ingredients!.isNotEmpty)
                  PUOverflowTextDetector(
                    message: item.ingredients!.join(', '),
                    children: [
                      Text(
                        item.ingredients!.join(', '),
                        style: PuTextStyle.ingredientsListStyle.copyWith(
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                // Precio y botón
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.price!.toString().convertToCorrency(),
                      style: PuTextStyle.nameProductStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
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
