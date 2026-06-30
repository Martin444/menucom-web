import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:pu_material/atoms/product_image.dart';
import 'package:pu_material/atoms/product_title.dart';
import 'package:pu_material/atoms/product_price.dart';
import 'package:pu_material/atoms/product_badge.dart';
import 'package:pu_material/atoms/product_additional_info.dart';
import 'package:pu_material/atoms/atom_button.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/analytics_service.dart';
import 'package:menucom_catalog/core/analytics_events.dart';

/// Organismo: Vista detalle de producto
class ProductDetailPage extends StatelessWidget {
  factory ProductDetailPage.fromArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final CatalogItemModel? item = args['item'] as CatalogItemModel?;

    if (item != null) {
      AnalyticsService().logEvent(
        name: AnalyticsEvents.productViewed,
        parameters: {
          AnalyticsParams.productId: item.id ?? '',
          AnalyticsParams.productName: item.name,
          AnalyticsParams.productPrice: item.price,
          AnalyticsParams.productCategory: item.category ?? '',
        },
      );
    }

    return ProductDetailPage(
      name: args['name'] is String ? args['name'] : '',
      description: args['description'] is String ? args['description'] : '',
      photoUrl: args['photoUrl'] is String ? args['photoUrl'] : '',
      price: args['price'] is String ? args['price'] : '0.0',
      brand: args['brand'] as String?,
      sizes: args['sizes'] as List<String>?,
      color: args['color'] as String?,
      onAddCart: args['onAddCart'],
      item: item,
    );
  }

  final String name;
  final String description;
  final String photoUrl;
  final String price;
  final String? brand;
  final List<String>? sizes;
  final String? color;
  final Function(CatalogItemModel)? onAddCart;
  final CatalogItemModel? item;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.price,
    this.brand,
    this.sizes,
    this.color,
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
                      child: GetBuilder<HomeController>(
                        builder: (controller) {
                          final isAdded = item != null
                              ? controller.detectItemInList(item!)
                              : false;

                          final displayBrand = brand ?? (item?.attributes?['brand'] as String? ?? '');
                          final displaySizes = sizes ?? ((item?.attributes?['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []);
                          final displayColor = color ?? (item?.attributes?['color'] as String? ?? '');

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductTitle(title: name),
                              if (displayBrand.isNotEmpty) ProductAdditionalInfo(text: displayBrand, prefix: 'Marca: '),
                              const SizedBox(height: 8),
                              if (displaySizes.isNotEmpty) ProductAdditionalInfo(text: displaySizes.join(", "), prefix: 'Talles: '),
                              if (displayColor.isNotEmpty) ProductAdditionalInfo(text: displayColor, prefix: 'Color: '),
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
                                    onAddCart!(item!);
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
