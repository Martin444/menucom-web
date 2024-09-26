import 'package:menucom_catalog/features/home/data/provider/get_wardrobe_provider.dart';
import 'package:menucom_catalog/features/home/models/wardrobe_response_params.dart';

class GetClothingUserUsescase {
  GetClothingUserUsescase();

  Future<WardrobeResponseParams> execute(String id) async {
    try {
      var response = await GetClothingProvider().getClothingByUserAcount(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
