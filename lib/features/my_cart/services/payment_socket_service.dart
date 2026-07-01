import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:menucom_catalog/core/config.dart';

class PaymentSocketService {
  IO.Socket? _socket;

  void connect({
    required String orderId,
    required void Function(dynamic data) onPaymentSuccess,
  }) {
    _closeExistingSocket();

    final wsUrl = AppConfig.webSocketUrl;

    _socket = IO.io(
      wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[SOCKET] Conectado al gateway de pagos, suscribiendo a room: $orderId');
      _socket!.emit('subscribeToOrder', orderId);
    });

    _socket!.onReconnect((_) {
      debugPrint('[SOCKET] Reconectado, resuscribiendo a room: $orderId');
      _socket!.emit('subscribeToOrder', orderId);
    });

    _socket!.on('paymentSuccess', (data) {
      debugPrint('[SOCKET] Pago exitoso para la orden: ${data['orderId']}');
      onPaymentSuccess(data);
      disconnect();
    });

    _socket!.onDisconnect((_) => debugPrint('[SOCKET] Desconectado'));
    _socket!.onConnectError((err) => debugPrint('[SOCKET] Error de conexión: $err'));
    _socket!.onReconnectAttempt((attempt) => debugPrint('[SOCKET] Intento de reconexión #$attempt'));

    _socket!.onAny((event, data) {
      debugPrint('[SOCKET] Evento: $event, data: $data');
    });

    _socket!.connect();
  }

  void disconnect() {
    _closeExistingSocket();
  }

  void _closeExistingSocket() {
    try {
      _socket?.offAny();
      _socket?.disconnect();
      _socket?.destroy();
    } catch (e) {
      debugPrint('[SOCKET] Error cerrando socket previo: $e');
    }
    _socket = null;
  }

  void dispose() {
    _closeExistingSocket();
  }
}
