import 'package:get/get.dart';
import 'package:pickme_up_web/core/middlewares/name_middleware.dart';
import 'package:pickme_up_web/features/my_cart/presentation/pages/my_cart_page.dart';
import 'package:pickme_up_web/routes/routes.dart';

import '../features/home/presentation/getx/menu_binding.dart';
import '../features/home/presentation/page/home_page.dart';

class PUPages {
  static final List<GetPage> pagesRoutes = [
    GetPage(
      middlewares: [
        NameMiddleware(),
      ],
      name: PURoutes.HOME,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      bindings: [MenuHomeBinding()],
    ),
    GetPage(
      name: PURoutes.MYCART,
      page: () => const MyCartPage(),
      bindings: [MenuHomeBinding()],
      transition: Transition.fadeIn,
    ),
  ];
}
