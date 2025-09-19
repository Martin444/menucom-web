import 'package:flutter/material.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:pu_material/atoms/product_image.dart';
import 'package:pu_material/atoms/product_title.dart';
import 'package:pu_material/atoms/product_price.dart';
import 'package:pu_material/atoms/product_badge.dart';
import 'package:pu_material/atoms/product_additional_info.dart';
import 'package:pu_material/atoms/atom_button.dart';
import 'package:get/get.dart';

/// Organismo: Vista detalle de producto
class ProductDetailPage extends StatelessWidget {
  factory ProductDetailPage.fromArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return ProductDetailPage(
      name: args['name'] is String ? args['name'] : '',
      brand: args['brand'] is String ? args['brand'] : '',
      description: args['description'] is String ? args['description'] : '',
      photoUrl: args['photoUrl'] is String ? args['photoUrl'] : '',
      price: args['price'] is String ? args['price'] : '',
      sizes: args['sizes'] is List ? (args['sizes'] as List).map((e) => e.toString()).toList() : <String>[],
      color: args['color'] is String ? args['color'] : '',
      onAddCart: args['onAddCart'],
      item: args['item'],
    );
  }
  final String name;
  final String brand;
  final String description;
  final String photoUrl;
  final String price;
  final List<String> sizes;
  final String color;
  final dynamic onAddCart;
  final dynamic item;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.brand,
    required this.description,
    required this.photoUrl,
    required this.price,
    required this.sizes,
    required this.color,
    this.onAddCart,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ProductImage(
                      imageUrl: photoUrl,
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GetBuilder<MenuHomeCartController>(
                        builder: (controller) {
                          final isMenuItem = item != null && item.runtimeType.toString().contains('MenuItemModel');
                          final isAdded = item != null
                              ? (isMenuItem ? controller.detectItemInList(item) : controller.detectItemInWardrobe(item))
                              : false;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductTitle(title: name),
                              if (brand.isNotEmpty) ProductAdditionalInfo(text: brand, prefix: 'Marca: '),
                              const SizedBox(height: 8),
                              if (sizes.isNotEmpty) ProductAdditionalInfo(text: sizes.join(", "), prefix: 'Talles: '),
                              if (color.isNotEmpty) ProductAdditionalInfo(text: color, prefix: 'Color: '),
                              const SizedBox(height: 16),
                              ProductPrice(price: double.tryParse(price) ?? 0.0),
                              const SizedBox(height: 16),
                              if (description.isNotEmpty) ProductBadge(text: description),
                              const SizedBox(height: 24),
                              AtomButton(
                                label: isAdded ? 'Agregado' : 'Agregar al carrito',
                                onPressed: () {
                                  if (isAdded) return;
                                  if (onAddCart != null && item != null) {
                                    onAddCart(item);
                                    controller.update();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Producto agregado al carrito')),
                                    );
                                  }
                                },
                                backgroundColor: isAdded ? Colors.grey[400] : Colors.blue[600],
                                textColor: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 16,
            child: AtomButton(
              label: '←',
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              backgroundColor: Colors.white,
              textColor: Colors.black,
              padding: const EdgeInsets.all(8),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper para mostrar el detalle como dialog en web o fullscreen en mobile
void showProductDetail(
  BuildContext context, {
  required String name,
  required String brand,
  required String description,
  required String photoUrl,
  required String price,
  required List<String> sizes,
  required String color,
}) {
  final isWeb = MediaQuery.of(context).size.width > 600;
  final detail = ProductDetailPage(
    name: name,
    brand: brand,
    description: description,
    photoUrl: photoUrl,
    price: price,
    sizes: sizes,
    color: color,
  );
  if (isWeb) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: detail,
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => detail),
    );
  }
}
