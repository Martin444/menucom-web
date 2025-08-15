import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_binding.dart';
import 'package:menucom_catalog/features/home/presentation/page/home_page.dart';
import 'package:menucom_catalog/features/my_cart/getx/order_binding.dart';
import 'package:menucom_catalog/features/my_cart/presentation/pages/confirm_order_page.dart';
import 'package:menucom_catalog/features/my_cart/presentation/pages/my_cart_page.dart';
import 'package:menucom_catalog/features/my_cart/presentation/pages/checkout_status_page.dart';
import 'package:menucom_catalog/routes/routes.dart';

class PUPages {
  static final List<GetPage> pagesRoutes = [
    GetPage(
      name: PURoutes.HOME,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      bindings: [
        MenuHomeBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.MYCART,
      page: () => const MyCartPage(),
      bindings: [
        MenuHomeBinding(),
        OrderBinding(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PURoutes.CONFIRMORDER,
      page: () => const ConfirmOrderPage(),
      bindings: [
        MenuHomeBinding(),
        OrderBinding(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PURoutes.CHECKOUT_STATUS,
      page: () => const CheckoutStatusPage(),
      bindings: [
        OrderBinding(),
      ],
      transition: Transition.fadeIn,
    ),
  ];
}
