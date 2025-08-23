import 'package:flutter/material.dart';
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
    super.key,
    required this.isMobile,
    this.orderController,
    this.status = OrderStatus.confirmed,
    this.showStatusAnimation = false,
    this.customOrderId,
    this.customClientId,
    this.customDate,
    this.customInfoItems,
  });

  int _getStatusIndex() {
    const statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.confirmed,
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
      infoItems: customInfoItems ?? [],
      showStatusAnimation: showStatusAnimation,
      showProgressIndicator: showStatusAnimation,
      currentStep: _getStatusIndex(),
      totalSteps: 5,
    );
  }
}
