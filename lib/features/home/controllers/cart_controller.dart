import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';

/// Modelo para items en el carrito con cantidad
class CartItem {
  final MenuItemModel menuItem;
  final RxInt quantity;

  CartItem({
    required this.menuItem,
    int initialQuantity = 1,
  }) : quantity = initialQuantity.obs;

  /// Precio total del item (precio unitario * cantidad)
  double get totalPrice => (menuItem.price?.toDouble() ?? 0.0) * quantity.value;

  /// ID único del item de menú
  String get itemId => menuItem.id ?? '';

  /// Nombre del item
  String get name => menuItem.name ?? '';

  /// URL de la foto del item
  String? get photoUrl => menuItem.photoUrl;

  /// Precio unitario
  double get unitPrice => menuItem.price?.toDouble() ?? 0.0;

  /// Ingredientes del item
  List<String> get ingredients => menuItem.ingredients ?? [];

  /// Tiempo de entrega estimado
  int get deliveryTime => menuItem.deliveryTime ?? 30;
}

/// Controlador especializado para manejo del carrito de compras
/// Responsable de gestionar items, cantidades, totales y persistencia
class CartController extends GetxController {
  // Estado reactivo del carrito
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxDouble _subtotal = 0.0.obs;
  final RxDouble _tax = 0.0.obs;
  final RxDouble _total = 0.0.obs;
  final RxBool _isLoading = false.obs;

  // Configuración de impuestos (puede ser configurable)
  static const double _taxRate = 0.12; // 12% IVA

  // Getters públicos (solo lectura)
  List<CartItem> get cartItems => _cartItems;
  double get subtotal => _subtotal.value;
  double get tax => _tax.value;
  double get total => _total.value;
  bool get isLoading => _isLoading.value;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;
  int get itemCount => _cartItems.length;
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  /// Tiempo de entrega estimado (mayor tiempo entre todos los items)
  int get estimatedDeliveryTime {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.map((item) => item.deliveryTime).reduce((a, b) => a > b ? a : b);
  }

  @override
  void onInit() {
    super.onInit();
    // Escuchar cambios en las cantidades de items individuales
    ever(_cartItems, (_) => _calculateTotals());
  }

  /// Añade un item al carrito o incrementa la cantidad si ya existe
  void addItem(MenuItemModel menuItem, {int quantity = 1}) {
    if (quantity <= 0) return;

    final existingItemIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.itemId == menuItem.id,
    );

    if (existingItemIndex != -1) {
      // Item ya existe, incrementar cantidad
      _cartItems[existingItemIndex].quantity.value += quantity;
    } else {
      // Nuevo item, añadir al carrito
      final cartItem = CartItem(
        menuItem: menuItem,
        initialQuantity: quantity,
      );

      // Escuchar cambios en la cantidad de este item específico
      ever(cartItem.quantity, (_) => _calculateTotals());

      _cartItems.add(cartItem);
    }

    _calculateTotals();
  }

  /// Remueve un item del carrito completamente
  void removeItem(String itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.itemId == itemId);
    _calculateTotals();
  }

  /// Actualiza la cantidad de un item específico
  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final itemIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.itemId == itemId,
    );

    if (itemIndex != -1) {
      _cartItems[itemIndex].quantity.value = newQuantity;
      _calculateTotals();
    }
  }

  /// Incrementa la cantidad de un item
  void incrementItem(String itemId) {
    final item = _cartItems.firstWhereOrNull(
      (cartItem) => cartItem.itemId == itemId,
    );

    if (item != null) {
      item.quantity.value++;
      _calculateTotals();
    }
  }

  /// Decrementa la cantidad de un item
  void decrementItem(String itemId) {
    final item = _cartItems.firstWhereOrNull(
      (cartItem) => cartItem.itemId == itemId,
    );

    if (item != null) {
      if (item.quantity.value > 1) {
        item.quantity.value--;
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

  /// Obtiene un item del carrito por ID
  CartItem? getCartItem(String itemId) {
    try {
      return _cartItems.firstWhere(
        (cartItem) => cartItem.itemId == itemId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un item está en el carrito
  bool containsItem(String itemId) {
    return _cartItems.any((cartItem) => cartItem.itemId == itemId);
  }

  /// Obtiene la cantidad de un item específico en el carrito
  int getItemQuantity(String itemId) {
    final item = getCartItem(itemId);
    return item?.quantity.value ?? 0;
  }

  /// Calcula los totales del carrito
  void _calculateTotals() {
    double newSubtotal = 0.0;

    for (final cartItem in _cartItems) {
      newSubtotal += cartItem.totalPrice;
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
                'id': item.itemId,
                'name': item.name,
                'quantity': item.quantity.value,
                'unitPrice': item.unitPrice,
                'totalPrice': item.totalPrice,
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
        .map((cartItem) => OrderItemModel(
              id: int.tryParse(cartItem.itemId) ?? 0, // Convertir String ID a int
              productName: cartItem.name,
              quantity: cartItem.quantity.value,
              price: cartItem.unitPrice,
            ))
        .toList();
  }
}
