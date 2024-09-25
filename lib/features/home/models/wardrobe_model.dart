import 'package:menucom_catalog/features/home/models/clothing_item_model.dart';

class WardrobeModel {
  final String? id;
  final String? idOwner;
  final String? description;
  final int? capacity;
  final List<ClothingItemModel>? items;

  WardrobeModel({
    required this.id,
    required this.idOwner,
    this.description,
    this.capacity,
    required this.items,
  });

  factory WardrobeModel.fromJson(Map<String, dynamic> json) {
    return WardrobeModel(
      id: json['id'] as String?,
      idOwner: json['idOwner'] as String?,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      items: (json['items'] as List<dynamic>?)?.map((itemJson) => ClothingItemModel.fromJson(itemJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idOwner': idOwner,
      'description': description,
      'capacity': capacity,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}
