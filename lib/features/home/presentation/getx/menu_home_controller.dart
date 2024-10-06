import 'package:get/get.dart';
import 'package:menucom_catalog/core/exeptions/api_exception.dart';
import 'package:menucom_catalog/features/home/data/usecases/get_clothing_user_usescase.dart';
import 'package:menucom_catalog/features/home/data/usecases/get_menu_usecases.dart';
import 'package:menucom_catalog/features/home/models/clothing_item_model.dart';
import 'package:menucom_catalog/features/home/models/wardrobe_model.dart';
import 'package:pu_material/widgets/cards/cart/model/cart_item_model.dart';

import '../../models/menu_item_model.dart';
import '../../models/menu_model.dart';

class MenuHomeCartController extends GetxController {
  RxList<MenuModel> listMenu = <MenuModel>[].obs;
  RxList<MenuItemModel> listMenuItems = <MenuItemModel>[].obs;
  RxBool isLoadHomeItems = true.obs;
  RxString errorText = ''.obs;
  RxString nameComerce = ''.obs;

  void getItemsMenu({String? idMenu}) async {
    try {
      var response = await GetMenuUseCase().execute(idMenu!);
      nameComerce.value = response.owner!;
      listMenu.assignAll(response.listmenus!);
      for (var element in listMenu) {
        listMenuItems.assignAll(element.items!);
      }
      isLoadHomeItems.value = false;
      update();
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          await getWardrobebyDining(
            idMenu: idMenu,
          );
          return;
        }
        errorText.value = (e).message.toString();
        errorText.refresh();
      } else {
        errorText.value = 'No se pudieron traer los datos para $e';
      }
      update();
      // rethrow;
    }
  }

  List<WardrobeModel> wardList = <WardrobeModel>[];

  Future<List<WardrobeModel>?> getWardrobebyDining({String? idMenu}) async {
    try {
      wardList = [];
      final responseWar = await GetClothingUserUsescase().execute(idMenu!);
      nameComerce.value = responseWar.owner!;
      for (var e in responseWar.listClothing!) {
        wardList.add(e);
      }
      isLoadHomeItems.value = false;
      update();
      return wardList;
    } on ApiException catch (e) {
      update();
      if (e.statusCode == 404) {
        return null;
      }
      return null;
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

  void selectItemWard(ClothingItemModel item) {
    try {
      if (listMenuSelected.isEmpty) {
        listMenuSelected.add(
          CartItemModel(
            id: item.id,
            photoUrl: item.photoURL,
            name: item.name,
            price: item.price?.toInt(),
            quantity: 1,
            deliveryTime: 30,
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
        listMenuSelected.add(
          CartItemModel(
            id: item.id,
            photoUrl: item.photoURL,
            name: item.name,
            price: item.price?.toInt(),
            quantity: 1,
            deliveryTime: 30,
          ),
        );
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

  bool detectItemInWardrobe(ClothingItemModel item) {
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
