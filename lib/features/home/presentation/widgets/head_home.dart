import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class HeadHome extends StatelessWidget {
  final bool? withBack;
  final String? titleHead;
  final Function? onBack;
  const HeadHome({
    super.key,
    this.withBack,
    this.onBack,
    this.titleHead,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(builder: (_) {
      return Container(
        padding: const EdgeInsets.only(
          top: 15,
          right: 20,
          left: 10,
        ),
        decoration: PuStyleContainers.borderBottomContainer,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            withBack ?? false
                ? Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            onBack!();
                          },
                          child: SvgPicture.asset(
                            PUIcons.iconBack,
                            width: 50,
                            colorFilter: ColorFilter.mode(
                              PUColors.iconColor,
                              BlendMode.srcIn,
                            ),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Text(
                          titleHead ?? '',
                          style: PuTextStyle.titleHeadTextStyle,
                        ),
                      ],
                    ),
                  )
                : const Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 70,
                    ),
                  ),
            withBack ?? false
                ? const Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 50,
                    ),
                  )
                : Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: const Alignment(0, -1.4),
                          children: [
                            Text(
                              _.listMenuSelected.length.toString(),
                              style: PuTextStyle.cartQuantityTextStyle,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(PURoutes.MYCART);
                              },
                              child: Center(
                                child: SvgPicture.asset(
                                  PUIcons.iconCart,
                                  height: 40,
                                  colorFilter: ColorFilter.mode(
                                    PUColors.iconColorBlack,
                                    BlendMode.srcIn,
                                  ),
                                  fit: BoxFit.fitHeight,
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
    });
  }
}
