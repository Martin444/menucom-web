import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_dart_api/by_feature/wardrobe/get_clothing_bywardeobe/model/clothing_item_model.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class ClothingTile extends StatefulWidget {
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
  State<ClothingTile> createState() => _ClothingTileState();
}

class _ClothingTileState extends State<ClothingTile> {
  String formatDeliveryTime(int deliveryTime) {
    if (deliveryTime < 60) {
      return 'Entrega en $deliveryTime minutos';
    } else if (deliveryTime < 1440) {
      // Menos de un día
      int hours = deliveryTime ~/ 60;
      int minutes = deliveryTime % 60;
      return 'Entrega en $hours horas y $minutes minutos';
    } else {
      // Un día o más
      int days = deliveryTime ~/ 1440;
      int remainingMinutes = deliveryTime % 1440;
      int hours = remainingMinutes ~/ 60;
      int minutes = remainingMinutes % 60;
      return 'Entrega en $days días, $hours horas y $minutes minutos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 10,
      ),
      decoration: PuStyleContainers.borderAllContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.network(
            widget.item.photoURL!,
            height: 140,
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: PUOverflowTextDetector(
                    message: widget.item.name!,
                    children: [
                      Text(
                        widget.item.brand!,
                        style: PuTextStyle.brandHeadStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: PUOverflowTextDetector(
                        message: widget.item.name!,
                        children: [
                          Text(
                            widget.item.name!,
                            style: PuTextStyle.nameProductStyle,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: PUOverflowTextDetector(
                        message: widget.item.price!.toString().convertToCorrency(),
                        children: [
                          Text(
                            widget.item.price!.toString().convertToCorrency(),
                            textAlign: TextAlign.end,
                            style: PuTextStyle.nameProductStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    widget.onAddCart(widget.item);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: PUOverflowTextDetector(
                          message: widget.item.sizes?.join(',') ?? '',
                          children: [
                            Text(
                              widget.item.sizes?.join(', ') ?? '',
                              style: PuTextStyle.ingredientsListStyle,
                            ),
                          ],
                        ),
                      ),
                      widget.selected
                          ? SvgPicture.asset(
                              PUIcons.iconCheck,
                              height: 40,
                            )
                          : SvgPicture.asset(
                              PUIcons.iconCart,
                              height: 40,
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
