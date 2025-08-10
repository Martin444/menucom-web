import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/routes/routes.dart';

import 'package:pu_material/widgets/cards/cart/model/cart_item_model.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../presentation/widgets/order_status_config.dart';

class OrderController extends GetxController {
  IO.Socket? _socket;
  Rx<Order> orders = Order().obs;
  RxBool isLoading = true.obs;
  RxString errorText = ''.obs;

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
        );
      }).toList();
      final order = Order(
        // Asumiendo que Order tiene un constructor que acepta una lista de items
        items: orderItems, // Implementa toOrderItem() en CartItemModel si es necesario
        total: list.fold<double>(0.0, (double sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 1))),
      );
      print(order.toJson());
      Get.toNamed(PURoutes.CONFIRMORDER, arguments: order);
      orders.value = order;
      isLoading.value = false;
    } catch (e) {
      rethrow;
    }
  }

  // Controlador el estado de boton estado del header de confirmacion de pedido
  Rx<OrderStatus> orderStatus = OrderStatus.pending.obs;
  RxBool isOrderLoading = false.obs;

  // Función para guardar el dato de contacto en la orden generada
  void saveContactToLastOrder(String contact) async {
    final updatedOrder = orders.value.copyWith(customerEmail: contact);
    orders.value = updatedOrder;
    isOrderLoading.value = true;
    isOrderLoading.refresh();
    orderStatus.value = OrderStatus.processing;
    orderStatus.refresh();
    orders.refresh();
    var orderCreated = await CreateOrderUseCase().call(orders.value);
    if (orderCreated.id != null) {
      // Conectar al WebSocket y suscribirse a la room de la orden
      _connectAndSubscribeToOrder(orderCreated.operationID!);
      // orderStatus.value = OrderStatus.confirmed;
      // orderStatus.refresh();
      await redirectToMercadoPagoCheckout(orderCreated.paymentUrl!);
    } else {
      errorText.value = 'Error al crear la orden';
      errorText.refresh();
    }
  }

  void _connectAndSubscribeToOrder(String orderId) {
    // Cerrar conexiones previas
    try {
      _socket?.offAny();
      _socket?.disconnect();
      _socket?.destroy();
    } catch (e) {
      print('Error cerrando socket previo: $e');
    }

    // Usar solo la URL base para WebSocket (sin /payments/webhooks)
    String wsUrl = URL_PICKME_API;
    // Dejar la URL como https:// para que se conecte como antes

    // Si falla, probar con /socket.io
    _socket = IO.io(
      wsUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket!.onConnect((_) {
      print('Conectado al gateway de pagos');
      print('[SOCKET] Emitiendo subscribeToOrder con orderId: $orderId');
      _socket!.emit('subscribeToOrder', orderId);
    });

    _socket!.on('paymentSuccess', (data) {
      print('Pago exitoso para la orden: ${data['orderId']}');
      orderStatus.value = OrderStatus.confirmed;
      orderStatus.refresh();
      isOrderLoading.value = false;
      isOrderLoading.refresh();
      try {
        _socket?.disconnect();
        _socket?.destroy();
      } catch (e) {
        print('[SOCKET] Error cerrando socket tras paymentSuccess: $e');
      }
    });

    _socket!.onDisconnect((_) => print('Desconectado del gateway de pagos'));

    _socket!.on('connect_error', (err) {
      print('[SOCKET] Error de conexión: $err');
    });
    _socket!.on('error', (err) {
      print('[SOCKET] Error general: $err');
    });
    _socket!.on('reconnect_attempt', (attempt) {
      print('[SOCKET] Intento de reconexión #$attempt');
    });
    _socket!.on('reconnect', (_) {
      print('[SOCKET] Reconectado');
    });

    _socket!.onAny((event, data) {
      print('[SOCKET] Evento recibido: $event, data: $data');
    });

    try {
      _socket!.connect();
      print('[SOCKET] Llamada a connect() realizada');
    } catch (e) {
      print('[SOCKET] Error al llamar a connect(): $e');
    }
  }

  Future<void> redirectToMercadoPagoCheckout(String preferenceId) async {
    html.window.open(preferenceId, '_blank');
  }

  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.destroy();
    super.onClose();
  }
}
