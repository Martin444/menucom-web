import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_controller.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/atoms/pwa_install_button_atom.dart';

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
    return GetBuilder<HomeController>(builder: (controller) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: PUColors.glassBg,
              border: Border(
                bottom: BorderSide(
                  color: PUColors.glassBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: PUColors.glassShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  if (withBack ?? false) ...[
                    _buildBackButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titleHead ?? '',
                        style: PuTextStyle.titleHeadTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    // Logo o Título de la marca en Home si no hay back
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                  Obx(() {
                    final pwaCtrl = Get.find<PwaInstallController>();
                    if (!pwaCtrl.isInstallable) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PwaInstallButtonAtom(
                        onPressed: () => pwaCtrl.install(),
                        tooltip: 'Instalar aplicación',
                      ),
                    );
                  }),
                  _buildCartButton(controller),
                ],
              ),
            ),
          ),
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
  Widget _buildCartButton(HomeController controller) {
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
                  colorFilter: const ColorFilter.mode(
                    PUColors.iconColorBlack,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.fitHeight,
                ),
                // Cart badge con animación
                Positioned(
                  child: Obx(() {
                    final count = controller.cartItemCount;
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
