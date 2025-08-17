import 'package:flutter_test/flutter_test.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_response.dart';

void main() {
  group('MenuResponse', () {
    test('debe parsearse correctamente desde JSON', () {
      // Arrange - el JSON del backend
      final jsonResponse = {
        "owner": {
          "id": "12dd8541-48f3-4639-be7e-5029bd338f88",
          "photoURL": "http://res.cloudinary.com/photographer/image/upload/v1752924718/c3ojp5cr1mwrunb6wgti.png",
          "name": "Remeras Patronales",
          "email": "user@user.com",
          "phone": "3873413199",
          "role": "dinning",
          "createAt": "2025-07-19T14:31:59.272Z",
          "updateAt": "2025-07-19T14:31:59.272Z"
        },
        "listmenu": [
          {
            "id": "1afa17be-4f86-457f-b85b-2884c6bc6521",
            "idOwner": "12dd8541-48f3-4639-be7e-5029bd338f88",
            "description": "Menú del día",
            "capacity": 15,
            "items": [
              {
                "id": "a424df1e-f57c-4acb-9798-4ef7329573d3",
                "name": "Desayuno con cafe y churros",
                "photoURL": "http://res.cloudinary.com/photographer/image/upload/v1752925055/bbgmle3wy4hrylxao1zv.jpg",
                "price": 4999,
                "ingredients": ["Todos", "Azucar"],
                "deliveryTime": 15
              },
              {
                "id": "e34ccc0f-c47e-427f-af0f-278967d39b2b",
                "name": "Churrasco",
                "photoURL": "http://res.cloudinary.com/photographer/image/upload/v1752925600/n7bqg0sjmhgmaz9y1jtx.jpg",
                "price": 2,
                "ingredients": ["Todos", "papas", "carne", "cebolla", "palta", "huevo", "verduras"],
                "deliveryTime": 33
              }
            ]
          },
          {
            "id": "998ccbed-1ad7-4ab5-bd08-9a4b0ad89470",
            "idOwner": "12dd8541-48f3-4639-be7e-5029bd338f88",
            "description": "Desayunos",
            "capacity": 15,
            "items": []
          }
        ]
      };

      // Act - parsear el JSON
      final menuResponse = MenuResponse.fromJson(jsonResponse);

      // Assert - verificar que se parseó correctamente
      expect(menuResponse.owner, isNotNull);
      expect(menuResponse.owner!.id, equals("12dd8541-48f3-4639-be7e-5029bd338f88"));
      expect(menuResponse.owner!.name, equals("Remeras Patronales"));
      expect(menuResponse.owner!.email, equals("user@user.com"));
      expect(menuResponse.owner!.phone, equals("3873413199"));
      expect(menuResponse.owner!.role, equals("dinning"));
      expect(menuResponse.owner!.photoURL, isNotNull);

      expect(menuResponse.listmenus, isNotNull);
      expect(menuResponse.listmenus!.length, equals(2));

      // Verificar primer menú
      final firstMenu = menuResponse.listmenus![0];
      expect(firstMenu.id, equals("1afa17be-4f86-457f-b85b-2884c6bc6521"));
      expect(firstMenu.description, equals("Menú del día"));
      expect(firstMenu.capacity, equals(15));
      expect(firstMenu.items!.length, equals(2));

      // Verificar primer item del menú
      final firstItem = firstMenu.items![0];
      expect(firstItem.id, equals("a424df1e-f57c-4acb-9798-4ef7329573d3"));
      expect(firstItem.name, equals("Desayuno con cafe y churros"));
      expect(firstItem.price, equals(4999));
      expect(firstItem.deliveryTime, equals(15));
      expect(firstItem.ingredients!.length, equals(2));
      expect(firstItem.ingredients![0], equals("Todos"));
      expect(firstItem.ingredients![1], equals("Azucar"));

      // Verificar segundo menú (con items vacíos)
      final secondMenu = menuResponse.listmenus![1];
      expect(secondMenu.id, equals("998ccbed-1ad7-4ab5-bd08-9a4b0ad89470"));
      expect(secondMenu.description, equals("Desayunos"));
      expect(secondMenu.capacity, equals(15));
      expect(secondMenu.items!.length, equals(0));
    });

    test('debe manejar owner null', () {
      // Arrange
      final jsonResponse = {"owner": null, "listmenu": []};

      // Act
      final menuResponse = MenuResponse.fromJson(jsonResponse);

      // Assert
      expect(menuResponse.owner, isNull);
      expect(menuResponse.listmenus, isNotNull);
      expect(menuResponse.listmenus!.length, equals(0));
    });

    test('debe manejar listmenu null', () {
      // Arrange
      final jsonResponse = {
        "owner": {
          "id": "12dd8541-48f3-4639-be7e-5029bd338f88",
          "name": "Test Owner",
          "email": "test@test.com",
          "phone": "123456789",
          "role": "dinning",
          "createAt": "2025-07-19T14:31:59.272Z",
          "updateAt": "2025-07-19T14:31:59.272Z"
        },
        "listmenu": null
      };

      // Act
      final menuResponse = MenuResponse.fromJson(jsonResponse);

      // Assert
      expect(menuResponse.owner, isNotNull);
      expect(menuResponse.owner!.name, equals("Test Owner"));
      expect(menuResponse.listmenus, isNull);
    });

    test('debe manejar createAt y updateAt como objetos JSON', () {
      // Arrange - caso donde createAt y updateAt vienen como objetos JSON
      final jsonResponse = {
        "owner": {
          "id": "12dd8541-48f3-4639-be7e-5029bd338f88",
          "name": "Test Owner",
          "email": "test@test.com",
          "phone": "123456789",
          "role": "dinning",
          "createAt": {"date": "2025-07-19T14:31:59.272Z"}, // Como objeto con propiedad 'date'
          "updateAt": {"value": "2025-07-19T14:31:59.272Z"} // Como objeto con propiedad 'value'
        },
        "listmenu": []
      };

      // Act
      final menuResponse = MenuResponse.fromJson(jsonResponse);

      // Assert
      expect(menuResponse.owner, isNotNull);
      expect(menuResponse.owner!.name, equals("Test Owner"));
      expect(menuResponse.owner!.createAt, isNotNull); // Ahora debe parsearse correctamente
      expect(menuResponse.owner!.updateAt, isNotNull); // Ahora debe parsearse correctamente
      expect(menuResponse.listmenus, isNotNull);
    });

    test('debe manejar createAt y updateAt mal formados', () {
      // Arrange - caso donde createAt y updateAt vienen con formato incorrecto
      final jsonResponse = {
        "owner": {
          "id": "12dd8541-48f3-4639-be7e-5029bd338f88",
          "name": "Test Owner",
          "email": "test@test.com",
          "phone": "123456789",
          "role": "dinning",
          "createAt": {"invalid": "formato"}, // Objeto sin fecha válida
          "updateAt": 12345 // Número en lugar de string u objeto
        },
        "listmenu": []
      };

      // Act
      final menuResponse = MenuResponse.fromJson(jsonResponse);

      // Assert
      expect(menuResponse.owner, isNotNull);
      expect(menuResponse.owner!.name, equals("Test Owner"));
      expect(menuResponse.owner!.createAt, isNull); // Debe ser null porque no tiene formato válido
      expect(menuResponse.owner!.updateAt, isNull); // Debe ser null porque no es string ni objeto válido
      expect(menuResponse.listmenus, isNotNull);
    });
  });
}
