import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/head_home.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/cards/cart/cart_tile.dart';

import '../../../../routes/routes.dart';
import '../../../home/presentation/getx/menu_home_controller.dart';

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadHome(
            withBack: true,
            onBack: () {
              Get.toNamed(PURoutes.HOME);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tu carrito',
              style: PuTextStyle.title5,
            ),
          ),
          GetBuilder<MenuHomeCartController>(builder: (_) {
            return Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _.listMenuSelected.isNotEmpty
                        ? GridView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _.listMenuSelected.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth >= 700 ? 1 : 1,
                              mainAxisExtent: 130,
                              childAspectRatio: 0.2,
                              crossAxisSpacing: 19,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              return CartTile(
                                item: _.listMenuSelected[index]!,
                                onAddCart: (item) {
                                  _.addquantityItem(item);
                                },
                                onRemoveCart: (item) {
                                  _.removequantityItem(item);
                                },
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No seleccionaste ningun plato en el menú aún.',
                              textAlign: TextAlign.center,
                              style: PuTextStyle.description1,
                            ),
                          ),
                  );
                },
              ),
            );
          }),
          GetBuilder<MenuHomeCartController>(builder: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: PuTextStyle.title2,
                      ),
                      Text(
                        _.totalOrder.toString().convertToCorrency(),
                        style: PuTextStyle.title2,
                      ),
                    ],
                  ),
                  ButtonPrimary(
                    title: 'Continuar',
                    onPressed: () {},
                    load: false,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
