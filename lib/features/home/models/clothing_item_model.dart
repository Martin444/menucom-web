class ClothingItemModel {
  String? id;
  String? name;
  String? brand;
  List<String>? sizes;
  String? color;
  double? price;
  int? quantity;
  int? wardrobeId;
  String? photoURL;

  ClothingItemModel({
    this.id,
    this.name,
    this.brand,
    this.sizes,
    this.color,
    this.price,
    this.quantity,
    this.wardrobeId,
    this.photoURL,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      sizes: (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      color: json['color'] as String?,
      price: double.tryParse(json['price'].toString()),
      quantity: json['quantity'] as int?,
      wardrobeId: json['wardrobeId'] as int?,
      photoURL: json['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'sizes': sizes,
      'color': color,
      'price': price,
      'quantity': quantity,
      'wardrobeId': wardrobeId,
      'photoURL': photoURL,
    };
  }
}
