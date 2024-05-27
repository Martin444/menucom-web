import 'package:get/get.dart';
import 'package:pickme_up_web/core/exeptions/api_exception.dart';
import 'package:pickme_up_web/features/home/data/usecases/get_menu_usecases.dart';
import 'package:pu_material/widgets/cards/cart/model/cart_item_model.dart';

import '../../models/menu_item_model.dart';
import '../../models/menu_model.dart';

class MenuHomeCartController extends GetxController {
  RxList<MenuModel> listMenu = <MenuModel>[].obs;
  RxList<MenuItemModel> listMenuItems = <MenuItemModel>[].obs;
  RxString errorText = ''.obs;

  void getItemsMenu({String? idMenu}) async {
    try {
      var response = await GetMenuUseCase().execute(idMenu!);
      listMenu.assignAll(response);
      for (var element in listMenu) {
        listMenuItems.assignAll(element.items!);
      }
      update();
    } catch (e) {
      errorText.value = (e as ApiException).message.toString();
      errorText.refresh();
      update();
      // rethrow;
    }
  }

  RxList<CartItemModel?> listMenuSelected = <CartItemModel?>[].obs;

  void selectItemMenu(MenuItemModel item) {
    try {
      if (listMenuSelected.isEmpty) {
        listMenuSelected.add(
          CartItemModel(
            id: item.id,
            photoUrl: item.photoUrl,
            name: item.name,
            price: item.price,
            quantity: 1,
            deliveryTime: item.deliveryTime,
          ),
        );
        calculateTotal();
        update();
        return;
      }
      var itemFound = listMenuSelected.firstWhere(
        (element) => element?.id == item.id,
        orElse: () => null,
      );

      if (itemFound == null) {
        listMenuSelected.add(CartItemModel(
          id: item.id,
          photoUrl: item.photoUrl,
          name: item.name,
          price: item.price,
          quantity: 1,
          deliveryTime: item.deliveryTime,
        ));
      } else {
        listMenuSelected.remove(itemFound);
      }
      calculateTotal();
      update();
    } catch (e) {
      rethrow;
    }
  }

  void addquantityItem(CartItemModel item) {
    // crea una funcion que detecte el item, si está agrega un quantity, sino remueve uno.
    // si el quantity es menor a 1 o igual a 0, quitalo de la lista
    final existingItem = listMenuSelected.firstWhere(
      (element) => element?.id == item.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity = existingItem.quantity! + 1;
      update();
    }
    calculateTotal();
  }

  void removequantityItem(CartItemModel item) {
    // crea una funcion que detecte el item, si está agrega un quantity, sino remueve uno.
    // si el quantity es menor a 1 o igual a 0, quitalo de la lista
    final existingItem = listMenuSelected.firstWhere(
      (element) => element?.id == item.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity = existingItem.quantity! - 1;
      update();

      if (existingItem.quantity! < 1) {
        listMenuSelected.remove(existingItem);
      }
    }
    calculateTotal();
  }

  RxDouble totalOrder = 0.0.obs;

  void calculateTotal() {
    totalOrder.value = 0.0;
    for (var cartItem in listMenuSelected) {
      var total = cartItem!.quantity! * cartItem.price!;
      totalOrder.value += total;
    }
    update();
  }

  bool detectItemInList(MenuItemModel item) {
    try {
      var itemFound = listMenuSelected.firstWhere(
        (e) {
          return e?.id == item.id;
        },
        orElse: () => null,
      );
      return itemFound != null;
    } catch (e) {
      return false;
    }
  }
}
