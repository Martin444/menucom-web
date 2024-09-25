import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menucom_catalog/core/exeptions/api_exception.dart';
import 'package:menucom_catalog/features/home/models/wardrobe_response_params.dart';

import '../../../../core/config.dart';
import '../repository/get_clothing_repository.dart';

class GetClothingProvider extends GetClothingsRespository {
  @override
  Future<WardrobeResponseParams> getClothingByUserAcount(String idUser) async {
    Uri userURl = Uri.parse('$URL_PICKME_API/wardrobe/bydining/$idUser');
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

      var wardResponse = WardrobeResponseParams.fromJson(respJson);

      return wardResponse;
    } catch (e) {
      rethrow;
    }
  }
}
