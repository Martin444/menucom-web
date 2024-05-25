import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../../routes/routes.dart';
import '../config.dart';

class NameMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (NAME_USER.isEmpty) {
      return RouteSettings(name: PURoutes.REGISTER_USER);
    }
    return null;
  }
}
