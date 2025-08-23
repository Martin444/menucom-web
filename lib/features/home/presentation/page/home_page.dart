import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/owner_info_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/search_filter_bar.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/filter_summary_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/responsive_items_grid.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Header widgets como slivers
          SliverToBoxAdapter(
            child: Column(
              children: const [
                HeadHome(),
                OwnerInfoWidget(),
                SearchFilterBar(),
                FilterSummaryWidget(),
              ],
            ),
          ),

          // Contenido grid/list
          GetBuilder<MenuHomeCartController>(
            builder: (_) {
              if (_.isLoadHomeItems.value) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 400,
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
                  ),
                );
              } else {
                return const ResponsiveItemsSliver();
              }
            },
          ),
        ],
      ),
    );
  }
}
