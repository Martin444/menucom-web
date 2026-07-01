import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pu_material/pu_material.dart' hide Order, OrderItem;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../presentation/widgets/order_status_config.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/core/analytics_service.dart';
import 'package:menucom_catalog/core/analytics_events.dart';

class OrderController extends GetxController {
  IO.Socket? _socket;
  Rx<Order> orders = Order().obs;
  RxBool isLoading = true.obs;
  RxString errorText = ''.obs;

  static const String _orderStorageKey = 'pending_order_data';
  static const String _orderStatusKey = 'pending_order_status';

  // Variable para almacenar el ownerId (userId legacy)
  RxString ownerId = ''.obs;

  // Variable para almacenar el commerceId (multi-tenant)
  RxString commerceId = ''.obs;

  // Método para establecer los identificadores del comercio
  void setCommerceIdentifiers({
    String? ownerIdValue,
    String? commerceIdValue,
  }) {
    if (ownerIdValue != null) ownerId.value = ownerIdValue;
    if (commerceIdValue != null) commerceId.value = commerceIdValue;
  }

  // Método para establecer el ownerId (llamado desde la UI) — mantenido para compatibilidad
  void setOwnerId(String ownerIdValue) {
    ownerId.value = ownerIdValue;
  }

  // Método para limpiar los identificadores
  void clearCommerceIdentifiers() {
    ownerId.value = '';
    commerceId.value = '';
  }

  // Método para limpiar el ownerId cuando sea necesario
  void clearOwnerId() {
    ownerId.value = '';
    commerceId.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadPersistedOrder();
    
    // Escuchar cambios en la orden para persistirla
    ever(orders, (_) => _saveOrder());
    ever(orderStatus, (_) => _saveOrderStatus());
  }

  Future<void> _loadPersistedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_orderStorageKey);
      if (orderJson != null && orderJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(orderJson);
        orders.value = Order.fromJson(decoded);
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

  /// Limpia los datos de la orden persistida (ej. después de un pago exitoso o al vaciar carrito)
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

  //movemos para aqui la logica del Carrito de compras
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
        total: list.fold<double>(0.0, (double sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 1))),
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

  // Controlador el estado de boton estado del header de confirmacion de pedido
  Rx<OrderStatus> orderStatus = OrderStatus.pending.obs;
  RxBool isOrderLoading = false.obs;

  // Función para guardar el dato de contacto en la orden generada
  void saveContactToLastOrder(String contact) async {
    debugPrint('[ORDER] saveContactToLastOrder iniciado con contact: $contact');
    
    // Validación de información del comercio
    final currentOwnerId = ownerId.value.isNotEmpty ? ownerId.value : orders.value.ownerId;
    final currentCommerceId = commerceId.value.isNotEmpty ? commerceId.value : orders.value.commerceId;
    if ((currentOwnerId == null || currentOwnerId.isEmpty) && (currentCommerceId == null || currentCommerceId.isEmpty)) {
      debugPrint('[ORDER] ERROR: No hay información del comercio');
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

    debugPrint('[ORDER] Llamando a CreateOrderUseCase con orden: ${orders.value}');

    try {
      final orderCreated = await CreateOrderUseCase().call(orders.value);
      debugPrint(
          '[ORDER] Respuesta de CreateOrderUseCase: id=${orderCreated.id}, operationID=${orderCreated.operationID}, paymentUrl=${orderCreated.paymentUrl}');

      if (orderCreated.id != null) {
        if (orderCreated.operationID != null) {
          _connectAndSubscribeToOrder(orderCreated.operationID!);
        } else {
          debugPrint('[ORDER] WARNING: No se recibió operationID, no habrá actualizaciones en tiempo real.');
        }

        final raw = orderCreated.paymentUrl ?? '';
        final prefId = _extractPreferenceId(raw);

        debugPrint('[PAY] paymentUrl/raw="$raw" -> preferenceId="$prefId"');

        await _openMercadoPagoCheckout(
          preferenceId: prefId,
          redirectUrl: raw,
        );
      } else {
        debugPrint('[ORDER] ERROR: No se pudo crear la orden, id es null');
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

  // Intenta extraer el pref_id de una URL de MercadoPago, o devuelve vacío para forzar redirect
  String _extractPreferenceId(String value) {
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();
    
    // Si ya es un UUID o parece un ID de preferencia puro (sin ser URL)
    final isUrl = lower.startsWith('http://') || lower.startsWith('https://');
    if (!isUrl) {
      // Validar que no sea un UUID (operationID)
      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
      if (uuidRegex.hasMatch(value.trim())) return '';
      return value.trim();
    }

    try {
      final uri = Uri.parse(value);
      
      // 1. Buscar en query parameters: pref_id o preference_id
      final qPref = uri.queryParameters['pref_id'] ?? uri.queryParameters['preference_id'];
      if (qPref != null && qPref.isNotEmpty) return qPref;

      // 2. Buscar en segmentos del path
      final segments = uri.pathSegments;
      
      // Caso: .../checkout/preferences/<ID>
      final prefIdx = segments.indexOf('preferences');
      if (prefIdx >= 0 && prefIdx + 1 < segments.length) {
        final id = segments[prefIdx + 1];
        if (id.isNotEmpty) return id;
      }
      
      // Caso: .../pay/<ID> o similar (algunas URLs de MP simplificadas)
      if (segments.isNotEmpty && segments.last.contains('-') && segments.last.length > 10) {
         // Los pref_id suelen tener guiones y ser largos
         return segments.last;
      }

    } catch (e) {
      debugPrint('[PAY] _extractPreferenceId: error parseando URL: $e');
    }
    
    return '';
  }

  Future<void> _openMercadoPagoCheckout({required String preferenceId, String? redirectUrl}) async {
    debugPrint('[PAY] _openMercadoPagoCheckout preferenceId="$preferenceId" redirectUrl="${redirectUrl ?? ''}"');

    // Determinamos la URL final: prioridad a construirla con pref_id si es posible para asegurar producción
    // PERO si el prefId es de test (empieza con TEST-), respetamos la URL original si existe
    String targetUrl = '';
    
    if (preferenceId.isNotEmpty && !preferenceId.startsWith('TEST-')) {
      targetUrl = 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
      debugPrint('[PAY] Forzando URL de producción construida con preferenceId');
    } else if (redirectUrl != null && redirectUrl.isNotEmpty) {
      targetUrl = redirectUrl;
      debugPrint('[PAY] Usando redirectUrl original (podría ser sandbox)');
    } else if (preferenceId.isNotEmpty) {
      targetUrl = 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
      debugPrint('[PAY] Usando preferenceId (podría ser sandbox si empieza con TEST-)');
    }

    if (targetUrl.isEmpty) {
      debugPrint('[PAY] ERROR: No hay URL ni preferenceId para el checkout');
      errorText.value = 'Error: Información de pago insuficiente';
      Get.snackbar('Error de Pago', 'No se pudo generar el checkout de MercadoPago.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(204),
        colorText: Colors.white);
      isOrderLoading.value = false;
      return;
    }

    debugPrint('[PAY] Usando redirección a: $targetUrl');

    AnalyticsService().logEvent(
      name: AnalyticsEvents.paymentInitiated,
      parameters: {
        AnalyticsParams.orderId: _extractPreferenceId(targetUrl),
        AnalyticsParams.orderTotal: orders.value.total ?? 0,
        AnalyticsParams.paymentMethod: 'mercadopago',
      },
    );

    await redirectToMercadoPagoCheckout(targetUrl);
  }

  void _connectAndSubscribeToOrder(String orderId) {
    // Cerrar conexiones previas
    try {
      _socket?.offAny();
      _socket?.disconnect();
      _socket?.destroy();
    } catch (e) {
      debugPrint('Error cerrando socket previo: $e');
    }

    // Usar solo la URL base para WebSocket desde AppConfig
    String wsUrl = AppConfig.webSocketUrl;
    // Dejar la URL como https:// para que se conecte como antes

    // Si falla, probar con /socket.io
    // Configuración resiliente del socket
    _socket = IO.io(
      wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection() // Issue 2.3.1: Habilitar reconexión automática
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[SOCKET] Conectado al gateway de pagos');
      debugPrint('[SOCKET] Suscribiendo a room: $orderId');
      _socket!.emit('subscribeToOrder', orderId);
    });

    _socket!.onReconnect((_) {
      debugPrint('[SOCKET] Reconectado exitosamente');
      // Al reconectar, debemos volver a suscribirnos porque el socket id cambió
      _socket!.emit('subscribeToOrder', orderId);
    });

    _socket!.on('paymentSuccess', (data) {
      debugPrint('[SOCKET] Pago exitoso para la orden: ${data['orderId']}');
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

      // Cerrar modal si está abierto
      try {
        if (Get.isOverlaysOpen == true) {
          Get.back(closeOverlays: true);
        }
      } catch (_) {}
      
      _socket?.disconnect();
      _socket?.destroy();
      
      // Limpiar carrito y orden persistida tras éxito
      try {
        final cartController = Get.find<CartController>();
        cartController.clearCart();
        debugPrint('[SOCKET] Carrito limpiado tras pago exitoso');
      } catch (_) {}
      clearPersistedOrder();
    });

    _socket!.onDisconnect((_) => debugPrint('[SOCKET] Desconectado del servidor'));

    _socket!.onConnectError((err) {
      debugPrint('[SOCKET] Error de conexión: $err');
    });

    _socket!.onReconnectAttempt((attempt) {
      debugPrint('[SOCKET] Intento de reconexión #$attempt');
    });

    _socket!.onAny((event, data) {
      debugPrint('[SOCKET] Evento recibido: $event, data: $data');
    });

    try {
      _socket!.connect();
      debugPrint('[SOCKET] Llamada a connect() realizada');
    } catch (e) {
      debugPrint('[SOCKET] Error al llamar a connect(): $e');
    }
  }

  Future<void> redirectToMercadoPagoCheckout(String url) async {
    final uri = Uri.parse(url);
    debugPrint('[PAY] Intentando abrir URL de pago: $url');
    
    try {
      if (kIsWeb) {
        // En web, preferimos _self para evitar bloqueadores de popups y problemas de COOP
        // tras operaciones asíncronas (como la creación de la orden)
        await launchUrl(uri, webOnlyWindowName: '_self');
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'No se puede abrir la URL en este dispositivo';
        }
      }
    } catch (e) {
      debugPrint('[PAY] Error crítico al abrir URL: $e');
      Get.snackbar('Error de Redirección', 'No se pudo abrir la página de pago. Por favor, intenta de nuevo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(204),
          colorText: Colors.white);
      isOrderLoading.value = false;
    }
  }

  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.destroy();
    super.onClose();
  }
}
