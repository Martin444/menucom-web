import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menu_dart_api/core/services/anonymous_id_service.dart';

void main() {
  group('AnonymousIdService Tests', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test
      SharedPreferences.setMockInitialValues({});
    });

    test('debería generar un nuevo UUID cuando no existe uno almacenado', () async {
      final service = AnonymousIdService.instance;
      final anonymousId = await service.getOrCreateAnonymousId();

      expect(anonymousId, isNotNull);
      expect(anonymousId.length, 36); // UUID v4 length
      expect(anonymousId.contains('-'), true);
    });

    test('debería retornar el mismo UUID en llamadas consecutivas', () async {
      final service = AnonymousIdService.instance;
      final firstId = await service.getOrCreateAnonymousId();
      final secondId = await service.getOrCreateAnonymousId();

      expect(firstId, equals(secondId));
    });

    test('debería regenerar un nuevo UUID', () async {
      final service = AnonymousIdService.instance;
      final originalId = await service.getOrCreateAnonymousId();
      final newId = await service.regenerateAnonymousId();

      expect(originalId, isNot(equals(newId)));
      expect(newId.length, 36);
    });

    test('debería limpiar el UUID almacenado', () async {
      final service = AnonymousIdService.instance;

      // Generar un ID
      await service.getOrCreateAnonymousId();

      // Verificar que existe
      var currentId = await service.getCurrentAnonymousId();
      expect(currentId, isNotNull);

      // Limpiar
      await service.clearAnonymousId();

      // Verificar que se limpió
      currentId = await service.getCurrentAnonymousId();
      expect(currentId, isNull);
    });

    test('getCurrentAnonymousId debería retornar null cuando no hay ID', () async {
      final service = AnonymousIdService.instance;
      final currentId = await service.getCurrentAnonymousId();

      expect(currentId, isNull);
    });

    test('debería crear nuevo ID después de limpiar', () async {
      final service = AnonymousIdService.instance;

      // Generar un ID inicial
      final firstId = await service.getOrCreateAnonymousId();

      // Limpiar
      await service.clearAnonymousId();

      // Generar nuevo ID
      final newId = await service.getOrCreateAnonymousId();

      expect(firstId, isNot(equals(newId)));
      expect(newId, isNotNull);
      expect(newId.length, 36);
    });
  });
}
