import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:pu_material/pu_material.dart';

/// Widget que muestra la información del propietario del comercio
/// Refactorizado para usar atomic design con componentes de pu_material
class OwnerInfoWidget extends StatelessWidget {
  const OwnerInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        if (controller.ownerInfo.value == null) {
          return const SizedBox.shrink();
        }

        final owner = controller.ownerInfo.value!;

        return ContainerAtom(
          // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: BusinessCardMolecule(
            name: owner.name ?? 'Comercio sin nombre',
            category: 'Propietario del comercio',
            imageUrl: owner.photoURL ?? '',
            isVerified: true,
            contactInfo: _buildContactInfo(owner),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            elevation: 2,
            borderRadius: 12,
          ),
        );
      },
    );
  }

  /// Construye la lista de información de contacto del propietario
  List<ContactInfo> _buildContactInfo(dynamic owner) {
    final List<ContactInfo> contactInfo = [];

    if (owner.email != null && owner.email!.isNotEmpty) {
      contactInfo.add(
        ContactInfo(
          icon: Icons.email_outlined,
          value: owner.email!,
        ),
      );
    }

    if (owner.phone != null && owner.phone!.isNotEmpty) {
      contactInfo.add(
        ContactInfo(
          icon: Icons.phone_outlined,
          value: owner.phone!,
        ),
      );
    }

    return contactInfo;
  }
}
