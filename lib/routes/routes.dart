// ignore_for_file: non_constant_identifier_names

class PURoutes {
  static String HOME = '/';
  static String MYCART = '/mi-carrito';
  static String CONFIRMORDER = '/confirmar-pedido';
  static String CHECKOUT_STATUS = '/checkout/status';

  static String PRODUCT_DETAIL = '/product-detail';

  /// Ruta dinámica para capturar UUIDs de comercios
  /// Ejemplo: /2229f1e3-2152-474a-94fc-efd8327f6d0c
  /// ⚠️ Esta debe ir al final en pages.dart para no capturar rutas específicas
  static String COMMERCE_DETAIL = '/:commerceId';
}
