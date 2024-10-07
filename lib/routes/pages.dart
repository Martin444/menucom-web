import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_binding.dart';
import 'package:menucom_catalog/features/home/presentation/page/home_page.dart';
import 'package:menucom_catalog/features/my_cart/presentation/pages/my_cart_page.dart';
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
      ],
      transition: Transition.fadeIn,
    ),
  ];
}
