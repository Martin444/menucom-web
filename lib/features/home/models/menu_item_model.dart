class MenuItemModel {
  String? id;
  String? photoUrl;
  String? name;
  int? price;
  List<String>? ingredients;
  int? deliveryTime;

  MenuItemModel({
    this.id,
    this.photoUrl,
    this.name,
    this.price,
    this.ingredients,
    this.deliveryTime,
  });

  // Método para convertir un mapa (JSON) en una instancia de MenuItemModel
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String?,
      photoUrl: json['photoURL'] as String?,
      name: json['name'] as String?,
      price: json['price'] as int?,
      ingredients: List<String>.from(json['ingredients']),
      deliveryTime: json['deliveryTime'] as int?,
    );
  }
}
