import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/core/exeptions/api_exception.dart';
import 'package:menucom_catalog/features/home/data/repository/get_menu_repository.dart';
import 'package:menucom_catalog/features/home/models/menu_response.dart';

class GetMenuProvider extends GetMenuRespository {
  @override
  Future<MenuResponse> getmenuByDining(String idDining) async {
    Uri userURl = Uri.parse('$URL_PICKME_API/menu/bydining/$idDining');
    try {
      var response = await http.get(
        userURl,
      );
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode,
          response.body,
        );
      }
      var respJson = jsonDecode(response.body);

      var menuRespon = MenuResponse.fromJson(respJson);

      return menuRespon;
    } catch (e) {
      rethrow;
    }
  }
}
