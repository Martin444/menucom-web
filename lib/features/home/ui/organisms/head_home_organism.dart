import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

class HeadHomeOrganism extends StatelessWidget {
  final String commerceName;
  final String? commerceLogoUrl;
  final bool withBack;
  final String? titleHead;
  final VoidCallback? onBack;

  const HeadHomeOrganism({
    super.key,
    required this.commerceName,
    this.commerceLogoUrl,
    this.withBack = false,
    this.titleHead,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
                if (withBack) ...[
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
                  _buildOwnerAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: commerceName.isEmpty
                        ? const SizedBox()
                        : Text(
                            commerceName,
                            style: PuTextStyle.titleHeadTextStyle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerAvatar() {
    if (commerceLogoUrl == null || commerceLogoUrl!.isEmpty) {
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
          imageUrl: commerceLogoUrl!,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      ),
    );
  }

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
