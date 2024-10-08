import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pickme_up_web/features/home/presentation/getx/menu_home_controller.dart';
import 'package:pickme_up_web/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class HeadHome extends StatelessWidget {
  final bool? withBack;
  final Function? onBack;
  const HeadHome({
    super.key,
    this.withBack,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(builder: (_) {
      return Container(
        height: 100,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            withBack ?? false
                ? Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        onBack!();
                      },
                      child: SvgPicture.asset(
                        PUIcons.iconBack,
                        width: 50,
                        colorFilter: ColorFilter.mode(
                          PUColors.primaryBackground,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 70,
                    ),
                  ),
            Flexible(
              flex: 3,
              child: Text(
                '${_.nameComerce}',
                style: PuTextStyle.title1,
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
                          alignment: const Alignment(0, -0.8),
                          children: [
                            Text(
                              _.listMenuSelected.length.toString(),
                              style: PuTextStyle.description1,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(PURoutes.MYCART);
                              },
                              child: Center(
                                child: SvgPicture.asset(
                                  PUIcons.iconCart,
                                  height: 50,
                                  colorFilter: ColorFilter.mode(
                                    PUColors.bgButton,
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
