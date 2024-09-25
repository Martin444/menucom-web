import 'package:menucom_catalog/features/home/models/menu_model.dart';

class MenuResponse {
  String? owner;
  List<MenuModel>? listmenus;

  // Constructor
  MenuResponse({this.owner, this.listmenus});

  // fromJson
  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      owner: json['owner'],
      listmenus: json['listmenu'] != null
          ? List<MenuModel>.from(json['listmenu'].map((item) => MenuModel.fromJson(item)))
          : null,
    );
  }
}
