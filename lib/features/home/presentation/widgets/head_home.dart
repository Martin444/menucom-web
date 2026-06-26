import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

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
                    // Avatar del negocio en Home
                    _buildOwnerAvatar(controller),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final catalog = controller.catalogRx.value;
                        final name = catalog?.commerce?['name']?.toString() ?? catalog?.owner?['name']?.toString() ?? catalog?.name ?? '';
                        if (name.isEmpty) return const SizedBox();
                        return Text(
                          name,
                          style: PuTextStyle.titleHeadTextStyle.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Avatar circular del comercio (logo del negocio)
  Widget _buildOwnerAvatar(HomeController controller) {
    return Obx(() {
      final catalog = controller.catalogRx.value;
      final photoUrl = catalog?.commerce?['logoUrl']?.toString() ?? catalog?.owner?['photoURL']?.toString();
      if (photoUrl == null || photoUrl.isEmpty) {
        return const SizedBox(width: 40);
      }
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: PUColors.glassBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: PuRobustNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
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

}
