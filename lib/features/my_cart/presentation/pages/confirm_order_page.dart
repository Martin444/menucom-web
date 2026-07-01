import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/confirm_order_header.dart';
import 'package:menucom_catalog/features/my_cart/ui/organisms/products_section_organism.dart';
import 'package:menucom_catalog/features/my_cart/ui/organisms/totals_section_organism.dart';

import 'package:menucom_catalog/features/my_cart/presentation/widgets/confirm_order_actions.dart';
import 'package:menucom_catalog/features/my_cart/presentation/widgets/order_status_config.dart';

/// Confirm Order Page - Main page for order confirmation
class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({Key? key}) : super(key: key);

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> with TickerProviderStateMixin {
  final orderController = Get.find<OrderController>();
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth <= 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: 1.0 - (_slideAnimation.value / 30.0),
                child: Obx(() {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        ConfirmOrderHeader(
                          isMobile: isMobile,
                          orderController: orderController,
                          status: orderController.orderStatus.value,
                          showStatusAnimation: true,
                        ),
                        Expanded(
                          child: Container(
                            padding: isMobile
                                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                                : EdgeInsets.symmetric(
                                    horizontal: (MediaQuery.of(context).size.width - 600) / 2 > 20
                                        ? (MediaQuery.of(context).size.width - 600) / 2
                                        : 20,
                                    vertical: 12,
                                  ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ConfirmOrderContent(
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                    orderController: orderController,
                                  ),
                                  const SizedBox(height: 14),
                                  ConfirmOrderActions(
                                    isMobile: isMobile,
                                    orderController: orderController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Confirm Order Content Widget - Contains the main content sections
class ConfirmOrderContent extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final OrderController orderController;
  const ConfirmOrderContent({
    Key? key,
    required this.isMobile,
    required this.isTablet,
    required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductsSectionOrganism(
            isMobile: isMobile,
            isTablet: isTablet,
            orderController: orderController,
          ),
          const SizedBox(height: 32),
          TotalsSectionOrganism(orderController: orderController),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
