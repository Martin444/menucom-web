import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar el identificador anónimo persistente
/// que permite vincular órdenes en el backend sin requerir autenticación.
class AnonymousIdService {
  static const String _anonymousIdKey = 'anonymous_id';
  static const Uuid _uuid = Uuid();
  static AnonymousIdService? _instance;

  AnonymousIdService._();

  /// Singleton para obtener la instancia del servicio
  static AnonymousIdService get instance {
    _instance ??= AnonymousIdService._();
    return _instance!;
  }

  /// Obtiene o crea un ID anónimo persistente
  /// Garantiza que siempre retorna un valor no nulo
  Future<String> getOrCreateAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? anonymousId = prefs.getString(_anonymousIdKey);

      if (anonymousId == null || anonymousId.isEmpty) {
        // Generar nuevo UUID v4
        anonymousId = _uuid.v4();
        await prefs.setString(_anonymousIdKey, anonymousId);

        // Log solo en desarrollo para debugging
        assert(() {
          developer.log('Nuevo anonymousId generado: $anonymousId', name: 'AnonymousIdService');
          return true;
        }());
      }

      return anonymousId;
    } catch (e) {
      // En caso de error, generar un UUID temporal
      // (no persistente pero funcional)
      developer.log('Error obteniendo anonymousId de SharedPreferences: $e', name: 'AnonymousIdService', level: 1000);
      return _uuid.v4();
    }
  }

  /// Regenera un nuevo ID anónimo (útil para testing o reset)
  Future<String> regenerateAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newId = _uuid.v4();
      await prefs.setString(_anonymousIdKey, newId);

      assert(() {
        developer.log('AnonymousId regenerado: $newId', name: 'AnonymousIdService');
        return true;
      }());

      return newId;
    } catch (e) {
      developer.log('Error regenerando anonymousId: $e', name: 'AnonymousIdService', level: 1000);
      return _uuid.v4();
    }
  }

  /// Limpia el ID anónimo almacenado
  Future<void> clearAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_anonymousIdKey);

      assert(() {
        developer.log('AnonymousId limpiado', name: 'AnonymousIdService');
        return true;
      }());
    } catch (e) {
      developer.log('Error limpiando anonymousId: $e', name: 'AnonymousIdService', level: 1000);
    }
  }

  /// Obtiene el ID anónimo actual sin generar uno nuevo
  /// Retorna null si no existe
  Future<String?> getCurrentAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_anonymousIdKey);
    } catch (e) {
      developer.log('Error obteniendo anonymousId actual: $e', name: 'AnonymousIdService', level: 1000);
      return null;
    }
  }
}
