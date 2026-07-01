import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessProfileFooterOrganism extends StatelessWidget {
  final BusinessProfileModel profile;
  final String commerceName;
  final String? commerceLogoUrl;

  const BusinessProfileFooterOrganism({
    super.key,
    required this.profile,
    required this.commerceName,
    this.commerceLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildBio(),
          ],
          if (profile.hours != null && profile.hours!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildHours(),
          ],
          if (profile.socialLinks != null && _hasSocialLinks) ...[
            const SizedBox(height: 24),
            _buildSocialLinks(),
          ],
          if (profile.coverage != null && profile.coverage!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildCoverage(),
          ],
          if (profile.policies != null && _hasPolicies) ...[
            const SizedBox(height: 24),
            _buildPolicies(),
          ],
          if (profile.certifications != null && profile.certifications!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildCertifications(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (commerceLogoUrl != null && commerceLogoUrl!.isNotEmpty)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PUColors.glassBorder, width: 1.5),
            ),
            child: ClipOval(
              child: PuRobustNetworkImage(
                imageUrl: commerceLogoUrl!,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
          ),
        if (commerceLogoUrl != null && commerceLogoUrl!.isNotEmpty)
          const SizedBox(width: 12),
        Expanded(
          child: Text(
            commerceName,
            style: PuTextStyle.title5.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre nosotros',
          style: PuTextStyle.title5.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Text(
          profile.bio!,
          style: PuTextStyle.bodySmall.copyWith(color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildHours() {
    final dayNames = {
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      'saturday': 'Sáb',
      'sunday': 'Dom',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios',
          style: PuTextStyle.title5.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: profile.hours!.map((hour) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hour.isHoliday ? Colors.grey[100] : PUColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayNames[hour.day.toLowerCase()] ?? hour.day,
                    style: PuTextStyle.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: hour.isHoliday ? Colors.grey[600] : PUColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hour.isHoliday ? 'Cerrado' : '${hour.open}-${hour.close}',
                    style: PuTextStyle.bodySmall.copyWith(
                      fontSize: 11,
                      color: hour.isHoliday ? Colors.grey[500] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    final links = profile.socialLinks!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redes',
          style: PuTextStyle.title5.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (links.instagram != null && links.instagram!.isNotEmpty)
              _buildSocialChip(Icons.camera_alt_outlined, 'Instagram', links.instagram!),
            if (links.facebook != null && links.facebook!.isNotEmpty)
              _buildSocialChip(Icons.facebook, 'Facebook', links.facebook!),
            if (links.whatsapp != null && links.whatsapp!.isNotEmpty)
              _buildSocialChip(Icons.chat_outlined, 'WhatsApp', links.whatsapp!),
            if (links.website != null && links.website!.isNotEmpty)
              _buildSocialChip(Icons.language, 'Web', links.website!),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialChip(IconData icon, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: PUColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: PUColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: PuTextStyle.bodySmall.copyWith(
                  color: PUColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverage() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 18, color: PUColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            profile.coverage!,
            style: PuTextStyle.bodySmall.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicies() {
    final policies = profile.policies!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Políticas',
          style: PuTextStyle.title5.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        if (policies.shipping != null && policies.shipping!.isNotEmpty)
          _buildPolicyItem('Envío', policies.shipping!, Icons.local_shipping_outlined),
        if (policies.returns != null && policies.returns!.isNotEmpty)
          _buildPolicyItem('Devoluciones', policies.returns!, Icons.assignment_return_outlined),
        if (policies.warranty != null && policies.warranty!.isNotEmpty)
          _buildPolicyItem('Garantía', policies.warranty!, Icons.verified_outlined),
        if (policies.payment != null && policies.payment!.isNotEmpty)
          _buildPolicyItem('Pago', policies.payment!, Icons.payment_outlined),
      ],
    );
  }

  Widget _buildPolicyItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: PUColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: PuTextStyle.bodySmall.copyWith(color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificaciones',
          style: PuTextStyle.title5.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.certifications!
              .map((cert) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          cert,
                          style: PuTextStyle.bodySmall.copyWith(
                            color: Colors.green[800],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  bool get _hasSocialLinks {
    final links = profile.socialLinks;
    if (links == null) return false;
    return (links.instagram?.isNotEmpty ?? false) ||
        (links.facebook?.isNotEmpty ?? false) ||
        (links.whatsapp?.isNotEmpty ?? false) ||
        (links.website?.isNotEmpty ?? false);
  }

  bool get _hasPolicies {
    final policies = profile.policies;
    if (policies == null) return false;
    return (policies.shipping?.isNotEmpty ?? false) ||
        (policies.returns?.isNotEmpty ?? false) ||
        (policies.warranty?.isNotEmpty ?? false) ||
        (policies.payment?.isNotEmpty ?? false);
  }

  Future<void> _launchUrl(String url) async {
    String fullUrl = url;
    if (!url.startsWith('http')) {
      fullUrl = 'https://$url';
    }
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
