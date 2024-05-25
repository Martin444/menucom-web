import 'dart:convert';

import 'package:pickme_up_web/core/config.dart';
import 'package:pickme_up_web/core/exeptions/api_exception.dart';
import 'package:pickme_up_web/features/home/data/repository/get_menu_repository.dart';
import 'package:http/http.dart' as http;

import '../../models/menu_model.dart';

class GetMenuProvider extends GetMenuRespository {
  @override
  Future<List<MenuModel>> getmenuByDining(String idDining) async {
    Uri userURl = Uri.parse('$URL_PICKME_API/menu/bydining/$idDining');
    try {
      var listItemsMenu = <MenuModel>[];
      var response = await http.get(
        userURl,
      );
      var respJson = jsonDecode(response.body);

      if (respJson['statusCode'] != null) {
        throw ApiException(
          respJson['statusCode'],
          respJson['message'],
        );
      }

      respJson.forEach((e) {
        listItemsMenu.add(MenuModel.fromJson(e));
      });
      return listItemsMenu;
    } catch (e) {
      rethrow;
    }
  }
}
