import '../../models/menu_model.dart';

abstract class GetMenuRespository {
  Future<List<MenuModel>> getmenuByDining(String idDining);
}
