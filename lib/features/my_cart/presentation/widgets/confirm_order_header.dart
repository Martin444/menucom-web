import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';
import 'package:pu_material/organisms/status_header.dart';
import 'package:pu_material/molecule/info_card.dart';
import 'order_status_config.dart';

class ConfirmOrderHeader extends StatelessWidget {
  final bool isMobile;
  final OrderController? orderController;
  final OrderStatus status;
  final bool showStatusAnimation;
  final String? customOrderId;
  final String? customClientId;
  final DateTime? customDate;
  final List<InfoItem>? customInfoItems;

  const ConfirmOrderHeader({
    Key? key,
    required this.isMobile,
    this.orderController,
    this.status = OrderStatus.confirmed,
    this.showStatusAnimation = false,
    this.customOrderId,
    this.customClientId,
    this.customDate,
    this.customInfoItems,
  }) : super(key: key);

  String _generateOrderId() {
    if (customOrderId != null) return customOrderId!;
    return 'ORD-2024-${(100000 + (DateTime.now().millisecondsSinceEpoch % 900000))}';
  }

  String _generateClientId() {
    if (customClientId != null) return customClientId!;
    return (1000000000 + (DateTime.now().millisecondsSinceEpoch % 9000000000)).toString();
  }

  String _formatDate() {
    final dateToFormat = customDate ?? DateTime.now();
    final formatter = DateFormat('d MMM yyyy, HH:mm', 'es_ES');
    return formatter.format(dateToFormat);
  }

  List<InfoItem> _buildInfoItems() {
    if (customInfoItems != null) return customInfoItems!;

    return [
      InfoItem(label: 'ID:', value: _generateOrderId()),
      InfoItem(label: 'Cliente:', value: _generateClientId()),
      InfoItem(label: 'Fecha:', value: _formatDate()),
    ];
  }

  int _getStatusIndex() {
    const statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    return statuses.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    final config = OrderStatusConfig.getConfig(status);

    return StatusHeader(
      isMobile: isMobile,
      config: config,
      infoItems: _buildInfoItems(),
      showStatusAnimation: showStatusAnimation,
      showProgressIndicator: showStatusAnimation,
      currentStep: _getStatusIndex(),
      totalSteps: 5,
    );
  }
}
