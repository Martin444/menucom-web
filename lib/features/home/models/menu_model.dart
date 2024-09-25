import 'package:menucom_catalog/features/home/models/menu_item_model.dart';

class MenuModel {
  String? id;
  String? idOwner;
  String? description;
  List<MenuItemModel>? items;

  MenuModel({
    this.id,
    this.description,
    this.idOwner,
    this.items,
  });

  // Método para convertir un mapa (JSON) en una instancia de MenuItemModel
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final List<MenuItemModel> menuItems =
        (json['items'] as List<dynamic>).map((itemJson) => MenuItemModel.fromJson(itemJson)).toList();

    return MenuModel(
      id: json['id'] as String?,
      description: json['description'] as String?,
      idOwner: json['idOwner'] as String?,
      items: menuItems,
    );
  }
}
