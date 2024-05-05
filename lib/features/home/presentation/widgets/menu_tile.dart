import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_up_web/features/home/models/menu_item_model.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: PUColors.primaryBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.network(
            item.photoUrl!,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 4,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                PUOverflowTextDetector(
                  message: item.name!,
                  children: [
                    Text(
                      item.name!,
                      style: PuTextStyle.title3,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    onAddCart(item);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: PUOverflowTextDetector(
                          message: item.price!.toString().convertToCorrency(),
                          children: [
                            Text(
                              item.price!.toString().convertToCorrency(),
                              style: PuTextStyle.description1,
                            ),
                          ],
                        ),
                      ),
                      selected
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
