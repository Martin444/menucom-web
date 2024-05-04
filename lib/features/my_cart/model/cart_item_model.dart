class CartItemModel {
  String? id;
  String? photoUrl;
  String? name;
  int? price;
  int? quantity;
  int? deliveryTime;

  CartItemModel({
    this.id,
    this.photoUrl,
    this.name,
    this.price,
    this.quantity,
    this.deliveryTime,
  });

  // Método para convertir un mapa (JSON) en una instancia de CartItemModel
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String?,
      photoUrl: json['photoURL'] as String?,
      name: json['name'] as String?,
      price: json['price'] as int?,
      quantity: json['quantity'] as int?,
      deliveryTime: json['deliveryTime'] as int?,
    );
  }
}
