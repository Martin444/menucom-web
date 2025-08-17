import 'package:flutter/material.dart';
import 'package:pu_material/organisms/status_header.dart';

/// Order Status Enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  failed,
}

/// Order Status Configuration Provider
class OrderStatusConfig {
  static const Map<OrderStatus, StatusHeaderConfig> configs = {
    OrderStatus.pending: StatusHeaderConfig(
      gradientColors: [Color(0xFFff9800), Color(0xFFf57c00)],
      iconBackgroundColor: Color(0xFFff9800),
      icon: Icons.schedule,
      title: '¡Orden Pendiente!',
      subtitle: 'Esperando confirmación',
    ),
    OrderStatus.confirmed: StatusHeaderConfig(
      gradientColors: [Color(0xFF4CAF50), Color(0xFF45a049)],
      iconBackgroundColor: Color(0xFF4CAF50),
      icon: Icons.check,
      title: '¡Orden Confirmada!',
      subtitle: 'Tu pedido ha sido confirmado',
    ),
    OrderStatus.processing: StatusHeaderConfig(
      gradientColors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      iconBackgroundColor: Color(0xFF2196F3),
      icon: Icons.sync,
      title: '¡Procesando Orden!',
      subtitle: 'Preparando tu pedido',
    ),
    OrderStatus.shipped: StatusHeaderConfig(
      gradientColors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      iconBackgroundColor: Color(0xFF9C27B0),
      icon: Icons.local_shipping,
      title: '¡Orden Enviada!',
      subtitle: 'Tu pedido está en camino',
    ),
    OrderStatus.delivered: StatusHeaderConfig(
      gradientColors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      iconBackgroundColor: Color(0xFF4CAF50),
      icon: Icons.check_circle,
      title: '¡Orden Entregada!',
      subtitle: 'Tu pedido ha sido entregado',
    ),
    OrderStatus.cancelled: StatusHeaderConfig(
      gradientColors: [Color(0xFF757575), Color(0xFF424242)],
      iconBackgroundColor: Color(0xFF757575),
      icon: Icons.cancel,
      title: 'Orden Cancelada',
      subtitle: 'El pedido ha sido cancelado',
    ),
    OrderStatus.failed: StatusHeaderConfig(
      gradientColors: [Color(0xFFf44336), Color(0xFFd32f2f)],
      iconBackgroundColor: Color(0xFFf44336),
      icon: Icons.error,
      title: 'Error en la Orden',
      subtitle: 'Hubo un problema con tu pedido',
    ),
  };

  static StatusHeaderConfig getConfig(OrderStatus status) {
    return configs[status]!;
  }

  /// Maps MercadoPago payment status to OrderStatus
  static OrderStatus mapPaymentStatusToOrderStatus(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'approved':
      case 'success':
        return OrderStatus.confirmed;
      case 'pending':
      case 'in_process':
        return OrderStatus.processing;
      case 'rejected':
      case 'failure':
      case 'cancelled':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }
}
