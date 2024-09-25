import 'package:menucom_catalog/features/home/data/provider/get_menu_provider.dart';
import 'package:menucom_catalog/features/home/models/menu_response.dart';

class GetMenuUseCase {
  GetMenuUseCase();

  Future<MenuResponse> execute(String id) async {
    try {
      var response = await GetMenuProvider().getmenuByDining(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
