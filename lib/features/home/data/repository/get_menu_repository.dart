import 'package:menucom_catalog/features/home/models/menu_response.dart';

abstract class GetMenuRespository {
  Future<MenuResponse> getmenuByDining(String idDining);
}
