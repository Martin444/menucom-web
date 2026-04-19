import 'package:flutter_test/flutter_test.dart';
import 'package:menu_dart_api/menu_com_api.dart';

void main() {
  group('CatalogModel', () {
    test('debe parsearse correctamente desde JSON', () {
      final jsonResponse = {
        "id": "cat-123",
        "catalogType": "menu",
        "name": "Menú Principal",
        "description": "El catálogo de comida",
        "ownerId": "owner-456",
        "status": "active",
        "slug": "menu-principal",
        "isPublic": true,
        "itemCount": 2,
        "capacity": 50,
        "createdAt": "2024-03-20T10:00:00Z",
        "updatedAt": "2024-03-20T11:00:00Z",
        "items": [
          {
            "id": "item-1",
            "catalogId": "cat-123",
            "name": "Hamburguesa",
            "description": "Con queso",
            "photoURL": "https://example.com/hamburguesa.jpg",
            "price": 1500.0,
            "quantity": 10,
            "status": "available",
            "isAvailable": true,
            "isFeatured": true,
            "displayOrder": 1,
            "createdAt": "2024-03-20T10:00:00Z",
            "updatedAt": "2024-03-20T11:00:00Z",
            "attributes": {
              "ingredients": ["Pan", "Carne", "Queso"]
            }
          },
          {
            "id": "item-2",
            "catalogId": "cat-123",
            "name": "Pizza",
            "description": "Muzzarella",
            "photoURL": "https://example.com/pizza.jpg",
            "price": 2000.0,
            "quantity": 5,
            "status": "available",
            "isAvailable": true,
            "isFeatured": false,
            "displayOrder": 2,
            "createdAt": "2024-03-20T10:00:00Z",
            "updatedAt": "2024-03-20T11:00:00Z"
          }
        ]
      };

      final catalog = CatalogModel.fromJson(jsonResponse);

      expect(catalog.id, equals("cat-123"));
      expect(catalog.name, equals("Menú Principal"));
      expect(catalog.ownerId, equals("owner-456"));
      expect(catalog.items, isNotNull);
      expect(catalog.items!.length, equals(2));

      final firstItem = catalog.items![0];
      expect(firstItem.name, equals("Hamburguesa"));
      expect(firstItem.price, equals(1500.0));
      expect(firstItem.attributes, isNotNull);
      expect(firstItem.attributes!['ingredients'], contains("Carne"));
    });

    test('debe manejar campos opcionales nulos', () {
      final jsonResponse = {
        "id": "cat-empty",
        "catalogType": "clothing",
        "ownerId": "owner-789",
        "status": "active",
        "slug": "vacio",
        "isPublic": false,
        "itemCount": 0,
        "capacity": 10,
        "createdAt": "2024-03-20T10:00:00Z",
        "updatedAt": "2024-03-20T11:00:00Z"
      };

      final catalog = CatalogModel.fromJson(jsonResponse);

      expect(catalog.name, isNull);
      expect(catalog.items, isNull);
      expect(catalog.isPublic, isFalse);
    });
  });
}
