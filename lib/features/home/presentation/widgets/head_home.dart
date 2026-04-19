import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
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
    return GetX<HomeController>(builder: (_) {
      return Container(
        padding: const EdgeInsets.only(
          top: 15,
          right: 20,
          left: 10,
          bottom: 15,
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
                        _buildBackButton(),
                        const SizedBox(width: 8),
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
                        _buildCartButton(),
                      ],
                    ),
                  ),
          ],
        ),
      );
    });
  }

  /// Botón de back con hover state y accessibility
  Widget _buildBackButton() {
    return Semantics(
      label: 'Regresar',
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onBack?.call(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              PUIcons.iconBack,
              width: 40,
              colorFilter: ColorFilter.mode(
                PUColors.iconColor,
                BlendMode.srcIn,
              ),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }

  /// Icono del carrito con hover state, badge y accessibility
  Widget _buildCartButton() {
    return Semantics(
      label: 'Ver carrito de compras',
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Get.toNamed(PURoutes.MYCART),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: const Alignment(0, -1.4),
              children: [
                SvgPicture.asset(
                  PUIcons.iconCart,
                  height: 36,
                  colorFilter: ColorFilter.mode(
                    PUColors.iconColorBlack,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.fitHeight,
                ),
                // Cart badge con animación
                Positioned(
                  child: Obx(() {
                    final count = HomeController().cartItemCount;
                    if (count <= 0) return const SizedBox.shrink();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PUColors.restaurantPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: PuTextStyle.cartQuantityTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
