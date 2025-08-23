import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class OwnerInfoWidget extends StatelessWidget {
  const OwnerInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (_) {
        if (_.ownerInfo.value == null) {
          return const SizedBox.shrink();
        }

        final owner = _.ownerInfo.value!;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar del owner
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PUColors.primaryBackground,
                ),
                child: owner.photoURL != null && owner.photoURL!.isNotEmpty
                    ? ClipOval(
                        child: PuRobustNetworkImage(
                          imageUrl: owner.photoURL!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          clearCacheOnError: true,
                        ),
                      )
                    : Icon(
                        Icons.store,
                        color: PUColors.primaryColor,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              // Información del owner
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.name ?? 'Comercio sin nombre',
                      style: PuTextStyle.title2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (owner.email != null && owner.email!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              owner.email!,
                              style: PuTextStyle.description1.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (owner.phone != null && owner.phone!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            owner.phone!,
                            style: PuTextStyle.description1.copyWith(
                              color: Colors.grey[600],
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
      },
    );
  }
}
