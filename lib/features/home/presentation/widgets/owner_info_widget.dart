import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/pu_material.dart';

/// Widget que muestra la información del catálogo o comercio
class OwnerInfoWidget extends StatelessWidget {
  const OwnerInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final catalog = controller.catalog;
        
        if (catalog == null) {
          return const SizedBox.shrink();
        }

        return ContainerAtom(
          child: BusinessCardMolecule(
            name: catalog.name ?? 'Catálogo',
            category: catalog.catalogType.capitalizeFirst ?? 'Comercio',
            imageUrl: catalog.coverImageUrl ?? '',
            isVerified: true,
            contactInfo: _buildContactInfo(catalog),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            elevation: 2,
            borderRadius: 12,
          ),
        );
      },
    );
  }

  /// Construye la lista de información de contacto basada en los metadatos del catálogo
  List<ContactInfo> _buildContactInfo(dynamic catalog) {
    final List<ContactInfo> contactInfo = [];
    
    // Intentar extraer email y teléfono de la metadata si existe
    if (catalog.metadata != null) {
      final email = catalog.metadata!['email'];
      final phone = catalog.metadata!['phone'];

      if (email != null && email.toString().isNotEmpty) {
        contactInfo.add(
          ContactInfo(
            icon: Icons.email_outlined,
            value: email.toString(),
          ),
        );
      }

      if (phone != null && phone.toString().isNotEmpty) {
        contactInfo.add(
          ContactInfo(
            icon: Icons.phone_outlined,
            value: phone.toString(),
          ),
        );
      }
    }

    return contactInfo;
  }
}
