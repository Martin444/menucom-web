import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/presentation/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/menu_tile.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class MenuHomeView extends StatefulWidget {
  const MenuHomeView({super.key});

  @override
  State<MenuHomeView> createState() => _MenuHomeViewState();
}

class _MenuHomeViewState extends State<MenuHomeView> {
  var cartcon = Get.find<MenuHomeCartController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuHomeCartController>(
      builder: (_) {
        if (_.listMenu.length == 1) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Text(
                  _.listMenu[0].description!,
                  style: PuTextStyle.title5,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _.listMenu[0].items!.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth >= 700 ? 6 : 2,
                          mainAxisExtent: 260,
                          childAspectRatio: 0.2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                        ),
                        itemBuilder: (context, index) {
                          return MenuTile(
                            item: _.listMenu[0].items![index],
                            selected: cartcon.detectItemInList(_.listMenu[0].items![index]),
                            onAddCart: (v) {
                              cartcon.selectItemMenu(_.listMenu[0].items![index]);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          itemCount: _.listMenu.length,
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (contx, index) {
            final menuEntry = _.listMenu[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Text(
                    menuEntry.description!,
                    style: PuTextStyle.title5,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 270,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: menuEntry.items!.length,
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 300,
                      childAspectRatio: 0.2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                          left: 20,
                        ),
                        decoration: PuStyleContainers.borderAllContainer,
                        child: MenuTile(
                          item: menuEntry.items![index],
                          selected: cartcon.detectItemInList(
                            menuEntry.items![index],
                          ),
                          onAddCart: (v) {
                            cartcon.selectItemMenu(
                              menuEntry.items![index],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
