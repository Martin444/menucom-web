import 'dart:convert';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/organisms/cart/model/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:menucom_catalog/core/analytics_service.dart';
import 'package:menucom_catalog/core/analytics_events.dart';

/// Controlador especializado para manejo del carrito de compras
/// Responsable de gestionar items, cantidades, totales y persistencia
class CartController extends GetxController {
  // Estado reactivo del carrito
  final RxList<CartItemModel> _cartItems = <CartItemModel>[].obs;
  final RxDouble _subtotal = 0.0.obs;
  final RxDouble _tax = 0.0.obs;
  final RxDouble _total = 0.0.obs;
  final RxBool _isLoading = false.obs;
  
  // Claves para persistencia
  static const String _cartStorageKey = 'shopping_cart_items';
  static const String _cartOwnerKey = 'shopping_cart_owner_id';

  // Configuración de impuestos (puede ser configurable)
  static const double _taxRate = 0.0; // Desactivado por ahora según lógica previa

  // Getters públicos (solo lectura)
  List<CartItemModel> get cartItems => _cartItems;
  RxList<CartItemModel> get cartItemsRx => _cartItems;

  double get subtotal => _subtotal.value;
  RxDouble get subtotalRx => _subtotal;

  double get tax => _tax.value;
  RxDouble get taxRx => _tax;

  double get total => _total.value;
  RxDouble get totalRx => _total;

  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;
  int get itemCount => _cartItems.length;
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  /// Tiempo de entrega estimado (mayor tiempo entre todos los items)
  int get estimatedDeliveryTime {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.map((item) => item.deliveryTime ?? 30).reduce((a, b) => a > b ? a : b);
  }

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    // Escuchar cambios en la lista
    ever(_cartItems, (_) {
      _calculateTotals();
      _saveCart();
    });
  }

  /// Carga el carrito desde el almacenamiento persistente
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString(_cartStorageKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(cartJson);
        final List<CartItemModel> loadedItems = decodedList
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
        
        if (loadedItems.isNotEmpty) {
          _cartItems.assignAll(loadedItems);
          _calculateTotals();
          debugPrint('[CART] Carrito cargado exitosamente: ${loadedItems.length} items');
        }
      }
    } catch (e) {
      debugPrint('[CART] Error al cargar el carrito: $e');
    }
  }

  /// Valida si el carrito pertenece al owner actual. Si cambió, lo limpia.
  Future<void> validateCartOwner(String currentOwnerId) async {
    if (currentOwnerId.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOwnerId = prefs.getString(_cartOwnerKey);
      
      if (savedOwnerId == null || savedOwnerId != currentOwnerId) {
        clearCart();
        await prefs.setString(_cartOwnerKey, currentOwnerId);
        debugPrint('[CART] Nuevo owner detectado, carrito limpiado');
      }
    } catch (e) {
      debugPrint('[CART] Error al validar owner del carrito: $e');
    }
  }

  /// Guarda el carrito en el almacenamiento persistente
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartStorageKey, cartJson);
    } catch (e) {
      debugPrint('[CART] Error al guardar el carrito: $e');
    }
  }

  /// Añade un item al carrito o incrementa la cantidad si ya existe
  void addItem(CatalogItemModel catalogItem, {int quantity = 1}) {
    if (quantity <= 0) return;

    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.id == catalogItem.id,
    );

    if (existingItemIndex != -1) {
      // Item ya existe, incrementar cantidad
      final item = _cartItems[existingItemIndex];
      _cartItems[existingItemIndex] = item.copyWith(
        quantity: (item.quantity ?? 0) + quantity,
      );
    } else {
      // Nuevo item, añadir al carrito
      final cartItem = CartItemModel(
        id: catalogItem.id,
        name: catalogItem.name,
        photoUrl: catalogItem.photoURL,
        price: catalogItem.price,
        quantity: quantity,
        deliveryTime: _extractDeliveryTime(catalogItem),
      );

      _cartItems.add(cartItem);
    }

    _calculateTotals();
    AnalyticsService().logEvent(
      name: AnalyticsEvents.cartAdd,
      parameters: {
        AnalyticsParams.itemId: catalogItem.id ?? '',
        AnalyticsParams.itemName: catalogItem.name ?? '',
        AnalyticsParams.productPrice: catalogItem.price,
        AnalyticsParams.cartTotal: _total.value,
        AnalyticsParams.cartQuantity: totalQuantity,
      },
    );
  }

  /// Remueve un item del carrito completamente
  void removeItem(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    _calculateTotals();
    AnalyticsService().logEvent(
      name: AnalyticsEvents.cartRemove,
      parameters: {
        AnalyticsParams.itemId: itemId,
        AnalyticsParams.cartTotal: _total.value,
        AnalyticsParams.cartQuantity: totalQuantity,
      },
    );
  }

  /// Actualiza la cantidad de un item específico
  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final itemIndex = _cartItems.indexWhere(
      (item) => item.id == itemId,
    );

    if (itemIndex != -1) {
      _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(quantity: newQuantity);
      _calculateTotals();
    }
  }

  /// Incrementa la cantidad de un item
  void incrementItem(String itemId) {
    final itemIndex = _cartItems.indexWhere(
      (item) => item.id == itemId,
    );

    if (itemIndex != -1) {
      final item = _cartItems[itemIndex];
      _cartItems[itemIndex] = item.copyWith(quantity: (item.quantity ?? 0) + 1);
      _calculateTotals();
    }
  }

  /// Decrementa la cantidad de un item
  void decrementItem(String itemId) {
    final itemIndex = _cartItems.indexWhere(
      (item) => item.id == itemId,
    );

    if (itemIndex != -1) {
      final item = _cartItems[itemIndex];
      if ((item.quantity ?? 0) > 1) {
        _cartItems[itemIndex] = item.copyWith(quantity: (item.quantity ?? 0) - 1);
        _calculateTotals();
      } else {
        removeItem(itemId);
      }
    }
  }

  /// Limpia completamente el carrito
  void clearCart() {
    _cartItems.clear();
    _calculateTotals();
  }

  /// Verifica si un item está en el carrito
  bool containsItem(String? itemId) {
    if (itemId == null) return false;
    return _cartItems.any((item) => item.id == itemId);
  }

  /// Obtiene la cantidad de un item específico en el carrito
  int getItemQuantity(String itemId) {
    final item = _cartItems.firstWhereOrNull((item) => item.id == itemId);
    return item?.quantity ?? 0;
  }

  /// Calcula los totales del carrito
  void _calculateTotals() {
    double newSubtotal = 0.0;

    for (final item in _cartItems) {
      newSubtotal += (item.price ?? 0.0) * (item.quantity ?? 0);
    }

    _subtotal.value = newSubtotal;
    _tax.value = newSubtotal * _taxRate;
    _total.value = newSubtotal + _tax.value;
  }

  /// Obtiene un resumen del carrito para el checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'items': _cartItems
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'unitPrice': item.price,
                'totalPrice': (item.price ?? 0.0) * (item.quantity ?? 0),
              })
          .toList(),
      'subtotal': _subtotal.value,
      'tax': _tax.value,
      'total': _total.value,
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'estimatedDeliveryTime': estimatedDeliveryTime,
    };
  }

  /// Convierte el carrito a formato para OrderParam (compatibilidad con menu_dart_api)
  List<OrderItemModel> toOrderItems() {
    return _cartItems
        .map((item) => OrderItemModel(
              id: int.tryParse(item.id ?? '') ?? 0, 
              productName: item.name ?? '',
              quantity: item.quantity ?? 0,
              price: item.price ?? 0.0,
            ))
        .toList();
  }

  int _extractDeliveryTime(CatalogItemModel item) {
    final time = item.attributes?['deliveryTime'];
    if (time is int) return time;
    if (time is String) return int.tryParse(time) ?? 30;
    return 30;
  }
}

