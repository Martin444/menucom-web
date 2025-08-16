import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';

/// Controller de ejemplo que demuestra el uso del Anonymous ID
/// para trackear usuarios anónimos en órdenes de compra
class AnonymousTrackingController extends GetxController {
  final _anonymousId = ''.obs;

  /// ID anónimo reactivo para la UI
  String get anonymousId => _anonymousId.value;

  @override
  void onInit() {
    super.onInit();
    _initializeAnonymousId();
  }

  /// Inicializa el ID anónimo al cargar el controller
  Future<void> _initializeAnonymousId() async {
    try {
      final id = await UniversalAnonymousIdService.instance.getOrCreateAnonymousId();
      _anonymousId.value = id;
    } catch (e) {
      // Log error usando developer.log en lugar de print
      developer.log('Error inicializando anonymous ID: $e', name: 'AnonymousTrackingController', level: 1000);
    }
  }

  /// Regenera un nuevo ID anónimo (útil para testing o logout)
  Future<void> regenerateAnonymousId() async {
    try {
      final newId = await UniversalAnonymousIdService.instance.regenerateAnonymousId();
      _anonymousId.value = newId;
      Get.snackbar(
        'ID Regenerado',
        'Se ha generado un nuevo ID anónimo: ${newId.substring(0, 8)}...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo regenerar el ID anónimo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Limpia el ID anónimo almacenado
  Future<void> clearAnonymousId() async {
    try {
      await UniversalAnonymousIdService.instance.clearAnonymousId();
      _anonymousId.value = '';
      Get.snackbar(
        'ID Limpiado',
        'Se ha eliminado el ID anónimo almacenado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo limpiar el ID anónimo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Ejemplo de cómo se enviaría una orden con el anonymous ID
  /// El header X-Anonymous-Id se agrega automáticamente via API.httpClient
  Future<void> sendOrderExample(Map<String, dynamic> orderData) async {
    try {
      // El cliente HTTP automáticamente agregará el header X-Anonymous-Id
      final response = await API.httpClient.post(
        Uri.parse('${API.defaulBaseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: orderData,
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Orden Enviada',
          'La orden se envió correctamente con ID anónimo',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error de Orden',
        'No se pudo enviar la orden: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Obtiene el ID actual sin generar uno nuevo
  Future<String?> getCurrentIdOnly() async {
    return await UniversalAnonymousIdService.instance.getCurrentAnonymousId();
  }
}
