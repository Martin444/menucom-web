import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/presentation/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/views/menu_home_view.dart';
import 'package:menucom_catalog/features/home/presentation/views/wardrobe_home_view.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/menu_tile.dart';
import 'package:pu_material/pu_material.dart';
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
    var currentRouteID = Uri.base;
    var iDdinning = currentRouteID.toString().split('/').last;

    cartcon.getItemsMenu(
      idMenu: iDdinning,
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    if (_.isLoadHomeItems.value) {
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
                      return Column(
                        children: [
                          Visibility(
                            visible: _.listMenu.isNotEmpty,
                            child: const MenuHomeView(),
                          ),
                          Visibility(
                            visible: _.wardList.isNotEmpty,
                            child: const WardrobeHomeView(),
                          )
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
