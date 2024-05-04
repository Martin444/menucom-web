import 'package:pickme_up_web/features/home/data/provider/get_menu_provider.dart';

import '../../models/menu_model.dart';

class GetMenuUseCase {
  GetMenuUseCase();

  Future<List<MenuModel>> execute(String id) async {
    try {
      var response = await GetMenuProvider().getmenuByDining(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
