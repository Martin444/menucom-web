import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/retry.dart';
import 'package:pickme_up_web/features/home/presentation/getx/menu_home_controller.dart';
import 'package:pickme_up_web/features/home/presentation/widgets/menu_tile.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../../models/menu_model.dart';
import '../widgets/head_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var cartcon = Get.find<MenuHomeCartController>();

  @override
  void initState() {
    cartcon.getItemsMenu(idMenu: 'c0da802a-e33c-498b-9917-30d8aed0b68a');
    super.initState();
  }

  List<Widget> getMyMenus(List<MenuModel> menu) {
    List<Widget> myWidget = [const Column()];

    for (var e in menu) {
      myWidget.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Text(
                  e.description!,
                  style: PuTextStyle.title5,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 233,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: e.items!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth >= 700 ? 6 : 1,
                        mainAxisExtent: 200,
                        childAspectRatio: 0.3,
                        crossAxisSpacing: 19,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                            left: 10,
                          ),
                          child: MenuTile(
                            item: e.items![index],
                            selected: cartcon.detectItemInList(e.items![index]),
                            onAddCart: (v) {
                              cartcon.selectItemMenu(e.items![index]);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    return myWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadHome(),
            const SizedBox(
              height: 20,
            ),
            GetBuilder<MenuHomeCartController>(
              builder: (_) {
                if (_.listMenu.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: _.errorText.value.isEmpty
                          ? const CircularProgressIndicator()
                          : Text(
                              _.errorText.value,
                              style: PuTextStyle.title5,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  );
                } else {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: _.listMenu[0].items!.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        constraints.maxWidth >= 700 ? 6 : 2,
                                    mainAxisExtent: 200,
                                    childAspectRatio: 0.2,
                                    crossAxisSpacing: 19,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemBuilder: (context, index) {
                                    return MenuTile(
                                      item: _.listMenu[0].items![index],
                                      selected: cartcon.detectItemInList(
                                          _.listMenu[0].items![index]),
                                      onAddCart: (v) {
                                        cartcon.selectItemMenu(
                                            _.listMenu[0].items![index]);
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (contx, index) {
                      final menuEntry = _.listMenu[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
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
                            height: 240,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: menuEntry.items!.length,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisExtent: 200,
                                childAspectRatio: 0.2,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 0,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                    left: 20,
                                  ),
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
