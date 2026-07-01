import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pu_material/pu_material.dart' hide Order, OrderItem;
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/core/services/google_auth_service.dart';

import '../presentation/widgets/order_status_config.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/core/analytics_service.dart';
import 'package:menucom_catalog/core/analytics_events.dart';
import 'package:menucom_catalog/features/my_cart/services/payment_socket_service.dart';
import 'package:menucom_catalog/features/my_cart/services/mercadopago_checkout_service.dart';

class OrderController extends GetxController {
  final PaymentSocketService _socketService = PaymentSocketService();

  Rx<Order> orders = Order().obs;
  RxBool isLoading = true.obs;
  RxString errorText = ''.obs;
  Rx<OrderStatus> orderStatus = OrderStatus.pending.obs;
  RxBool isOrderLoading = false.obs;

  static const String _orderStorageKey = 'pending_order_data';
  static const String _orderStatusKey = 'pending_order_status';

  RxString ownerId = ''.obs;
  RxString commerceId = ''.obs;

  // ── Identificadores del comercio ──

  void setCommerceIdentifiers({String? ownerIdValue, String? commerceIdValue}) {
    if (ownerIdValue != null) ownerId.value = ownerIdValue;
    if (commerceIdValue != null) commerceId.value = commerceIdValue;
  }

  void setOwnerId(String ownerIdValue) => ownerId.value = ownerIdValue;

  void clearCommerceIdentifiers() {
    ownerId.value = '';
    commerceId.value = '';
  }

  void clearOwnerId() => clearCommerceIdentifiers();

  // ── Lifecycle ──

  @override
  void onInit() {
    super.onInit();
    _loadPersistedOrder();
    ever(orders, (_) => _saveOrder());
    ever(orderStatus, (_) => _saveOrderStatus());
  }

  @override
  void onClose() {
    _socketService.dispose();
    super.onClose();
  }

  // ── Persistencia ──

  Future<void> _loadPersistedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_orderStorageKey);
      if (orderJson != null && orderJson.isNotEmpty) {
        orders.value = Order.fromJson(jsonDecode(orderJson) as Map<String, dynamic>);
        debugPrint('[ORDER] Orden persistida cargada');
      }
      final statusIndex = prefs.getInt(_orderStatusKey);
      if (statusIndex != null) {
        orderStatus.value = OrderStatus.values[statusIndex];
      }
    } catch (e) {
      debugPrint('[ORDER] Error al cargar orden persistida: $e');
    }
  }

  Future<void> _saveOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (orders.value.items != null && orders.value.items!.isNotEmpty) {
        await prefs.setString(_orderStorageKey, jsonEncode(orders.value.toJson()));
      } else {
        await prefs.remove(_orderStorageKey);
      }
    } catch (e) {
      debugPrint('[ORDER] Error al guardar orden: $e');
    }
  }

  Future<void> _saveOrderStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_orderStatusKey, orderStatus.value.index);
    } catch (e) {
      debugPrint('[ORDER] Error al guardar estado de orden: $e');
    }
  }

  Future<void> clearPersistedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_orderStorageKey);
      await prefs.remove(_orderStatusKey);
      orders.value = Order();
      orderStatus.value = OrderStatus.pending;
    } catch (e) {
      debugPrint('[ORDER] Error al limpiar orden persistida: $e');
    }
  }

  // ── Crear orden desde carrito ──

  RxList<CartItemModel?> listMenuToShell = <CartItemModel?>[].obs;

  Future<void> createOrder(List<CartItemModel> list) async {
    try {
      isLoading.value = true;
      if (list.isEmpty) {
        errorText.value = 'El carrito está vacío';
        isLoading.value = false;
        return;
      }

      final orderItems = list.map((cartItem) {
        return OrderItem(
          productName: cartItem.name ?? '',
          quantity: cartItem.quantity ?? 1,
          price: cartItem.price?.toDouble() ?? 0.0,
          sourceId: cartItem.id ?? '',
          sourceType: 'menu',
        );
      }).toList();

      final order = Order(
        items: orderItems,
        total: list.fold<double>(0.0, (sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 1))),
        status: 'pending',
        ownerId: ownerId.value.isNotEmpty ? ownerId.value : null,
        commerceId: commerceId.value.isNotEmpty ? commerceId.value : null,
      );

      Get.toNamed(PURoutes.CONFIRMORDER, arguments: order);
      orders.value = order;
      isLoading.value = false;

      AnalyticsService().logEvent(
        name: AnalyticsEvents.checkoutStarted,
        parameters: {
          AnalyticsParams.itemCount: list.length,
          AnalyticsParams.orderTotal: order.total ?? 0,
          AnalyticsParams.catalogId: order.commerceId ?? order.ownerId ?? '',
        },
      );
    } catch (e) {
      AnalyticsService().logErrorWithException(e, context: 'order_controller.createOrder');
      errorText.value = 'Error al preparar la orden';
      isLoading.value = false;
    }
  }

  // ── Checkout con MercadoPago ──

  void saveContactToLastOrder(String contact) async {
    debugPrint('[ORDER] saveContactToLastOrder iniciado con contact: $contact');

    final currentOwnerId = ownerId.value.isNotEmpty ? ownerId.value : orders.value.ownerId;
    final currentCommerceId = commerceId.value.isNotEmpty ? commerceId.value : orders.value.commerceId;

    if ((currentOwnerId == null || currentOwnerId.isEmpty) &&
        (currentCommerceId == null || currentCommerceId.isEmpty)) {
      errorText.value = 'Información del comercio incompleta';
      Get.snackbar(
        'Error de Comercio',
        'No se pudo identificar el comercio para procesar la orden.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(204),
        colorText: Colors.white,
      );
      return;
    }

    final contactInfo = contact.isNotEmpty ? contact : (USER_EMAIL.isNotEmpty ? USER_EMAIL : 'Cliente');

    final updatedOrder = orders.value.copyWith(
      customerEmail: contactInfo,
      ownerId: currentOwnerId,
      commerceId: currentCommerceId,
    );

    orders.value = updatedOrder;
    isOrderLoading.value = true;
    isOrderLoading.refresh();
    orderStatus.value = OrderStatus.processing;
    orderStatus.refresh();
    orders.refresh();

    try {
      final orderCreated = await CreateOrderUseCase().call(orders.value);
      debugPrint('[ORDER] Respuesta: id=${orderCreated.id}, operationID=${orderCreated.operationID}');

      if (orderCreated.id != null) {
        if (orderCreated.operationID != null) {
          _socketService.connect(
            orderId: orderCreated.operationID!,
            onPaymentSuccess: (data) => _onPaymentSuccess(data),
          );
        } else {
          debugPrint('[ORDER] WARNING: No operationID, sin actualizaciones en tiempo real.');
        }

        final raw = orderCreated.paymentUrl ?? '';
        final prefId = MercadoPagoCheckoutService.extractPreferenceId(raw);
        final targetUrl = MercadoPagoCheckoutService.buildCheckoutUrl(
          preferenceId: prefId,
          redirectUrl: raw,
        );

        if (targetUrl == null) {
          errorText.value = 'Error: Información de pago insuficiente';
          Get.snackbar('Error de Pago', 'No se pudo generar el checkout de MercadoPago.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withAlpha(204),
              colorText: Colors.white);
          isOrderLoading.value = false;
          return;
        }

        AnalyticsService().logEvent(
          name: AnalyticsEvents.paymentInitiated,
          parameters: {
            AnalyticsParams.orderId: prefId,
            AnalyticsParams.orderTotal: orders.value.total ?? 0,
            AnalyticsParams.paymentMethod: 'mercadopago',
          },
        );

        final success = await MercadoPagoCheckoutService.redirectToCheckout(targetUrl);
        if (!success) {
          Get.snackbar('Error de Redirección', 'No se pudo abrir la página de pago.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withAlpha(204),
              colorText: Colors.white);
          isOrderLoading.value = false;
        }
      } else {
        errorText.value = 'Error al crear la orden';
        errorText.refresh();
        isOrderLoading.value = false;
        orderStatus.value = OrderStatus.pending;
      }
    } catch (e) {
      debugPrint('[ORDER] Excepción al crear orden: $e');
      AnalyticsService().logErrorWithException(e, context: 'order_controller.saveContactToLastOrder');
      errorText.value = 'Error al procesar el pago. Intenta de nuevo.';
      errorText.refresh();
      isOrderLoading.value = false;
      orderStatus.value = OrderStatus.pending;
      Get.snackbar(
        'Error de Pago',
        'No se pudo procesar el pago. Verifica tu conexión e intenta de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(204),
        colorText: Colors.white,
      );
    }
  }

  Future<bool> loginAndConfirmOrder() async {
    try {
      final response = await GoogleAuthService().signInWithGoogle();
      if (response != null) {
        saveContactToLastOrder(NAME_USER);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ORDER] Error en login: $e');
      return false;
    }
  }

  void _onPaymentSuccess(dynamic data) {
    orderStatus.value = OrderStatus.confirmed;
    orderStatus.refresh();
    isOrderLoading.value = false;
    isOrderLoading.refresh();

    AnalyticsService().logEvent(
      name: AnalyticsEvents.checkoutCompleted,
      parameters: {
        AnalyticsParams.orderId: data['orderId']?.toString() ?? '',
        AnalyticsParams.orderTotal: orders.value.total ?? 0,
        AnalyticsParams.orderStatus: 'confirmed',
      },
    );

    try {
      if (Get.isOverlaysOpen == true) {
        Get.back(closeOverlays: true);
      }
    } catch (_) {}

    try {
      Get.find<CartController>().clearCart();
    } catch (_) {}

    clearPersistedOrder();
  }
}
