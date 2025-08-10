import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_controller.dart';
import 'package:pu_material/molecule/total_row.dart';

/// Widget that displays order totals, customizable with optional discount, shipping, and taxes.
class TotalsSection extends StatelessWidget {
  final OrderController orderController;
  final bool hasDiscount;
  final double discountPercentage;
  final bool hasShipping;
  final double shippingCost;
  final Function(double subtotal)? customTaxCalculator;

  const TotalsSection({
    Key? key,
    required this.orderController,
    this.hasDiscount = false,
    this.discountPercentage = 0.0,
    this.hasShipping = false,
    this.shippingCost = 0.0,
    this.customTaxCalculator,
  }) : super(key: key);

  /// Formats price with Argentinian currency format
  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    ).format(price);
  }

  /// Calculates totals based on the provided configuration.
  Map<String, double> _calculateTotals() {
    final subtotal = orderController.orders.value.items?.fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        ) ??
        0.0;

    final discount = hasDiscount ? subtotal * discountPercentage : 0.0;
    final shipping = hasShipping ? shippingCost : 0.0;
    final taxes = customTaxCalculator != null ? customTaxCalculator!(subtotal) : 0.0;
    final total = subtotal - discount + shipping + taxes;

    return {
      'subtotal': subtotal,
      'discount': discount,
      'shipping': shipping,
      'taxes': taxes,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totals = _calculateTotals();

      return Container(
        padding: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFf0f0f0), width: 2),
          ),
        ),
        child: Column(
          children: [
            _buildTotalRow(
              'Subtotal:',
              totals['subtotal']!,
              isFinal: false,
            ),
            const SizedBox(height: 12),
            if (hasDiscount)
              Column(
                children: [
                  _buildTotalRow(
                    'Descuento (-${(discountPercentage * 100).toInt()}%):',
                    -totals['discount']!,
                    isFinal: false,
                    color: const Color(0xFFe53935),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (hasShipping)
              Column(
                children: [
                  _buildTotalRow(
                    'Envío:',
                    totals['shipping']!,
                    isFinal: false,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (totals.containsKey('taxes') && totals['taxes']! > 0)
              Column(
                children: [
                  _buildTotalRow(
                    'Impuestos:',
                    totals['taxes']!,
                    isFinal: false,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            const SizedBox(height: 20),
            _buildFinalTotal(totals['total']!),
          ],
        ),
      );
    });
  }

  /// Builds a regular total row
  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isFinal = false,
    Color? color,
  }) {
    return TotalRow(
      label: label,
      amount: _formatPrice(amount),
      isFinal: isFinal,
      color: color,
    );
  }

  /// Builds the final total row with border
  Widget _buildFinalTotal(double total) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFe0e0e0), width: 2),
        ),
      ),
      child: _buildTotalRow('Total:', total, isFinal: true),
    );
  }
}
