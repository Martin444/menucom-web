import 'package:menucom_catalog/features/home/models/wardrobe_response_params.dart';

abstract class GetClothingsRespository {
  Future<WardrobeResponseParams> getClothingByUserAcount(String idUser);
}
