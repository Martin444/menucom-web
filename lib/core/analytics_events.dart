abstract class AnalyticsEvents {
  // ── Session ──
  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appResumed = 'app_resumed';

  // ── Auth (GA4 standard) ──
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';

  // ── Catálogo ──
  static const String catalogViewed = 'catalog_viewed';
  static const String catalogSelected = 'catalog_selected';
  static const String productViewed = 'product_viewed';

  // ── Búsqueda y Filtros ──
  static const String searchPerformed = 'search_performed';
  static const String filterApplied = 'filter_applied';
  static const String sortChanged = 'sort_changed';
  static const String filterCleared = 'filter_cleared';

  // ── Carrito ──
  static const String cartAdd = 'cart_add';
  static const String cartRemove = 'cart_remove';
  static const String cartViewed = 'cart_viewed';

  // ── Checkout ──
  static const String checkoutStarted = 'checkout_started';
  static const String checkoutCompleted = 'checkout_completed';
  static const String paymentInitiated = 'payment_initiated';

  // ── Navegación ──
  static const String viewModeChanged = 'view_mode_changed';

  // ── Sharing ──
  static const String catalogLinkCopied = 'catalog_link_copied';
  static const String catalogQrGenerated = 'catalog_qr_generated';
  static const String catalogShared = 'catalog_shared';

  // ── Errores ──
  static const String appError = 'app_error';
}

abstract class AnalyticsParams {
  // ── Genéricos ──
  static const String method = 'method';
  static const String name = 'name';
  static const String id = 'id';
  static const String type = 'type';
  static const String context = 'context';
  static const String error = 'error';
  static const String stackTrace = 'stack_trace';
  static const String source = 'source';
  static const String value = 'value';

  // ── Auth ──
  static const String loginMethod = 'loginMethod';
  static const String signUpMethod = 'signUpMethod';

  // ── Catálogo ──
  static const String catalogId = 'catalog_id';
  static const String catalogName = 'catalog_name';
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String productCategory = 'product_category';
  static const String productPrice = 'product_price';
  static const String price = 'price';
  static const String itemCount = 'item_count';

  // ── Búsqueda ──
  static const String searchQuery = 'search_query';
  static const String resultCount = 'result_count';
  static const String categories = 'categories';
  static const String sortOrder = 'sort_order';
  static const String filters = 'filters';

  // ── Carrito ──
  static const String cartTotal = 'cart_total';
  static const String cartQuantity = 'cart_quantity';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';

  // ── Checkout ──
  static const String orderId = 'order_id';
  static const String orderTotal = 'order_total';
  static const String orderStatus = 'order_status';
  static const String paymentMethod = 'payment_method';
  static const String totalRevenue = 'total_revenue';
  static const String status = 'status';

  // ── View Mode ──
  static const String viewMode = 'view_mode';
}
