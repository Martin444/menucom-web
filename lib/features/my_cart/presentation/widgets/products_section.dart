import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';
import 'package:pu_material/molecule/section_header.dart';

/// Products Section Widget
class ProductsSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final OrderController orderController;

  const ProductsSection({
    Key? key,
    required this.isMobile,
    required this.isTablet,
    required this.orderController,
  }) : super(key: key);

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  int _getTotalItemCount() {
    return orderController.orders.value.items?.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = isMobile ? 300.0 : (isTablet ? 350.0 : 400.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Productos',
          badgeText: '${_getTotalItemCount()} items',
        ),
        const SizedBox(height: 20),
        Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFe0e0e0)),
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFfafafa),
          ),
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final items = orderController.orders.value.items ?? [];
            if (items.isEmpty) {
              return const Center(
                child: Text('No hay productos en la orden'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ProductItem(
                  item: item,
                  isLast: index == items.length - 1,
                  formatPrice: _formatPrice,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

/// Product Item Widget
class ProductItem extends StatelessWidget {
  final dynamic item;
  final bool isLast;
  final String Function(double) formatPrice;

  const ProductItem({
    Key? key,
    required this.item,
    required this.isLast,
    required this.formatPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemTotal = item.price * item.quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFf5f5f5)),
              ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cantidad: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatPrice(itemTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2e7d32),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}