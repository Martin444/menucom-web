import 'package:get/get.dart';
import 'package:pu_material/widgets/cards/cart/model/cart_item_model.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/helpers/html_metadata_helper.dart';

class MenuHomeCartController extends GetxController {
  RxList<MenuModel> listMenu = <MenuModel>[].obs;
  RxList<MenuItemModel> listMenuItems = <MenuItemModel>[].obs;
  RxBool isLoadHomeItems = true.obs;
  RxString errorText = ''.obs;
  RxString nameComerce = ''.obs;

  // Nueva información del owner
  Rx<OwnerModel?> ownerInfo = Rx<OwnerModel?>(null);

  // Persistir el ID del menú/owner para usarlo en las órdenes
  RxString persistedOwnerId = ''.obs;

  // Filtrado y búsqueda
  RxString searchQuery = ''.obs;
  RxString selectedCategory = ''.obs;
  RxList<String> availableCategories = <String>[].obs;
  RxBool isGridView = true.obs;
  RxString sortBy = 'none'.obs; // 'none', 'name', 'price_low', 'price_high'

  // Datos filtrados
  RxList<MenuModel> filteredMenu = <MenuModel>[].obs;
  RxList<MenuItemModel> filteredMenuItems = <MenuItemModel>[].obs;
  List<WardrobeModel> filteredWardList = <WardrobeModel>[];

  // Método para obtener el ownerId persistido
  String get currentOwnerId => persistedOwnerId.value;

  // Método para limpiar el ownerId persistido
  void clearPersistedOwnerId() {
    persistedOwnerId.value = '';
  }

  // Métodos de filtrado y búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    sortBy.value = 'none';
    _applyFilters();
  }

  void setSortBy(String sortOption) {
    sortBy.value = sortOption;
    _applyFilters();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
    update();
  }

  void _updateCategories() {
    Set<String> categories = {'Todos'};

    // Agregar categorías de menús
    for (var menu in listMenu) {
      if (menu.description != null && menu.description!.isNotEmpty) {
        categories.add(menu.description!);
      }
    }

    // Agregar categorías de wardrobes
    for (var wardrobe in wardList) {
      if (wardrobe.description != null && wardrobe.description!.isNotEmpty) {
        categories.add(wardrobe.description!);
      }
    }

    availableCategories.value = categories.toList();
  }

  void _applyFilters() {
    String normalize(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r'[áàäâ]'), 'a')
          .replaceAll(RegExp(r'[éèëê]'), 'e')
          .replaceAll(RegExp(r'[íìïî]'), 'i')
          .replaceAll(RegExp(r'[óòöô]'), 'o')
          .replaceAll(RegExp(r'[úùüû]'), 'u');
    }

    String q = normalize(searchQuery.value.trim());
    bool isNumericQuery = int.tryParse(q) != null;

    // Filtrar menús
    filteredMenu.value = listMenu.where((menu) {
      bool matchesCategory = selectedCategory.value.isEmpty ||
          selectedCategory.value == 'Todos' ||
          (menu.description != null && normalize(menu.description!).contains(normalize(selectedCategory.value)));

      bool matchesSearch = q.isEmpty || (menu.description != null && normalize(menu.description!).contains(q));

      return matchesCategory && matchesSearch;
    }).toList();

    // Filtrar items de menú
    List<MenuItemModel> allFilteredItems = [];
    for (var menu in filteredMenu) {
      if (menu.items != null) {
        var filteredItems = menu.items!.where((item) {
          final name = item.name != null ? normalize(item.name!) : '';
          final ingredients = item.ingredients?.map(normalize).join(' ') ?? '';
          // final price = item.price?.toString() ?? '';
          // Puedes agregar más campos si los hay (ej: tags)

          bool match = q.isEmpty ||
              name.contains(q) ||
              ingredients.contains(q) ||
              (menu.description != null && normalize(menu.description!).contains(q));

          // Si la query es numérica, buscar por precio exacto
          if (isNumericQuery && item.price != null) {
            match = match || item.price.toString() == q;
          }
          return match;
        }).toList();
        _sortItems(filteredItems);
        allFilteredItems.addAll(filteredItems);
      }
    }
    filteredMenuItems.value = allFilteredItems;

    // Filtrar wardrobes
    filteredWardList = wardList.where((wardrobe) {
      bool matchesCategory = selectedCategory.value.isEmpty ||
          selectedCategory.value == 'Todos' ||
          (wardrobe.description != null &&
              normalize(wardrobe.description!).contains(normalize(selectedCategory.value)));

      bool matchesSearch = q.isEmpty || (wardrobe.description != null && normalize(wardrobe.description!).contains(q));

      return matchesCategory && matchesSearch;
    }).toList();

    // Filtrar items de wardrobe (sin modificar la lista original)
    for (var wardrobe in filteredWardList) {
      if (wardrobe.items != null) {
        final filteredItems = wardrobe.items!.where((item) {
          final name = item.name != null ? normalize(item.name!) : '';
          final brand = item.brand != null ? normalize(item.brand!) : '';
          final color = item.color != null ? normalize(item.color!) : '';
          // Puedes agregar más campos si los hay

          bool match = q.isEmpty ||
              name.contains(q) ||
              brand.contains(q) ||
              color.contains(q) ||
              (wardrobe.description != null && normalize(wardrobe.description!).contains(q));

          if (isNumericQuery && item.price != null) {
            match = match || item.price.toString() == q;
          }
          return match;
        }).toList();
        _sortClothingItems(filteredItems);
        // Si necesitas mostrar los items filtrados, puedes crear un nuevo objeto WardrobeModel temporal con estos items
        // o manejarlo en la UI usando filteredItems en vez de wardrobe.items
      }
    }

    // Aplicar ordenamiento a cada menú filtrado
    for (var menu in filteredMenu) {
      if (menu.items != null) {
        _sortItems(menu.items!);
      }
    }

    // Aplicar ordenamiento a wardrobes
    for (var wardrobe in filteredWardList) {
      if (wardrobe.items != null) {
        _sortClothingItems(wardrobe.items!);
      }
    }

    update();
  }

  void _sortItems(List<MenuItemModel> items) {
    switch (sortBy.value) {
      case 'name':
        items.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'price_low':
        items.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_high':
        items.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'none':
      default:
        // No ordenar
        break;
    }
  }

  void _sortClothingItems(List<ClothingItemModel> items) {
    switch (sortBy.value) {
      case 'name':
        items.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'price_low':
        items.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_high':
        items.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'none':
      default:
        // No ordenar
        break;
    }
  }

  // NOTA: Para usar el ownerId en OrderController, desde la UI se debe hacer:
  // 1. Obtener el MenuHomeController: final menuController = Get.find<MenuHomeCartController>();
  // 2. Obtener el OrderController: final orderController = Get.find<OrderController>();
  // 3. Establecer el ownerId: orderController.setOwnerId(menuController.currentOwnerId);
  // 4. Luego crear la orden: orderController.createOrder(listItems);

  void getItemsMenu({String? idMenu}) async {
    try {
      var response = await GetMenuUseCase().execute(idMenu!);

      // Persistir el ownerId si la respuesta es exitosa
      persistedOwnerId.value = idMenu;

      // Actualizar información del owner
      ownerInfo.value = response.owner;
      nameComerce.value = response.owner?.name ?? '';

      // ✅ Actualizar metadatos HTML (título, favicon, meta tags)
      if (response.owner != null) {
        HtmlMetadataHelper.updateCommerceMetadata(
          name: response.owner!.name ?? 'MenuCom',
          logoUrl: response.owner!.photoURL,
          description: 'Catálogo de productos y servicios',
        );
      }

      // Actualizar menús
      if (response.listmenus != null) {
        listMenu.assignAll(response.listmenus!);
        for (var element in listMenu) {
          if (element.items != null) {
            listMenuItems.addAll(element.items!);
          }
        }
      }

      // Actualizar categorías y aplicar filtros iniciales
      _updateCategories();
      _applyFilters();

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

      // Persistir el ownerId si la respuesta es exitosa
      persistedOwnerId.value = idMenu;

      nameComerce.value = responseWar.owner!;

      // ✅ Actualizar metadatos HTML (título, favicon, meta tags)
      // Nota: En wardrobe no tenemos photoURL en la respuesta actual,
      // pero actualizamos el título al menos
      HtmlMetadataHelper.updateTitle('${responseWar.owner} - MenuCom');

      for (var e in responseWar.listClothing!) {
        wardList.add(e);
      }

      // Actualizar categorías y aplicar filtros iniciales
      _updateCategories();
      _applyFilters();

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

  // Método para obtener todos los items filtrados (menús y wardrobes combinados)
  List<dynamic> getFilteredItems() {
    List<dynamic> allItems = [];

    // Agregar items de menú filtrados
    allItems.addAll(filteredMenuItems);

    // Agregar items de wardrobe filtrados (usando el mismo filtro flexible)
    String normalize(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r'[áàäâ]'), 'a')
          .replaceAll(RegExp(r'[éèëê]'), 'e')
          .replaceAll(RegExp(r'[íìïî]'), 'i')
          .replaceAll(RegExp(r'[óòöô]'), 'o')
          .replaceAll(RegExp(r'[úùüû]'), 'u');
    }

    String q = normalize(searchQuery.value.trim());
    bool isNumericQuery = int.tryParse(q) != null;

    for (var wardrobe in filteredWardList) {
      if (wardrobe.items != null) {
        final filteredItems = wardrobe.items!.where((item) {
          final name = item.name != null ? normalize(item.name!) : '';
          final brand = item.brand != null ? normalize(item.brand!) : '';
          final color = item.color != null ? normalize(item.color!) : '';
          bool match = q.isEmpty ||
              name.contains(q) ||
              brand.contains(q) ||
              color.contains(q) ||
              (wardrobe.description != null && normalize(wardrobe.description!).contains(q));
          if (isNumericQuery && item.price != null) {
            match = match || item.price.toString() == q;
          }
          return match;
        }).toList();
        allItems.addAll(filteredItems);
      }
    }

    return allItems;
  }

  // Método para determinar si estamos en modo menú o wardrobe
  bool get isMenuMode => wardList.isEmpty;

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
