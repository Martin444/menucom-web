import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/features/home/getx/menu_home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/owner_info_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/filter_summary_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/responsive_items_grid.dart';
import 'package:menucom_catalog/shared/utils/helpers/token_helper.dart';
import 'package:pu_material/pu_material.dart';

import '../widgets/head_home.dart';

/// HomePage - Página principal del catálogo siguiendo atomic design
///
/// Refactorizada para usar principios de atomic design:
/// - StatelessWidget para mejor rendimiento
/// - Separación clara de responsabilidades
/// - Uso de widgets de pu_material cuando es posible
/// - Estructura más limpia y mantenible
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar datos del menú al construir la página
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMenuData());

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: _buildNestedScrollView(),
    );
  }

  /// Inicializa los datos del menú basado en la URL actual
  void _initializeMenuData() {
    final cartController = Get.find<MenuHomeCartController>();
    final uri = Uri.base;

    // Extraer el ID del menú desde la ruta
    final menuId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

    // Extraer el token desde los query params y decodificarlo
    final rawToken = uri.queryParameters['token'] ?? '';
    final decodedToken = Uri.decodeComponent(rawToken);
    ACCESS_TOKEN = decryptAccessToken(decodedToken);

    API.setAccessToken(ACCESS_TOKEN);

    cartController.getItemsMenu(
      idMenu: menuId,
    );
  }

  /// Construye el NestedScrollView principal con header sticky
  Widget _buildNestedScrollView() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          _buildStaticHeader(),
          // _buildStickySearchFilter(),
        ];
      },
      body: _buildMainContent(),
    );
  }

  /// Construye el header estático que incluye navegación e información del propietario
  Widget _buildStaticHeader() {
    return const SliverToBoxAdapter(
      child: Column(
        children: [
          HeadHome(),
          OwnerInfoWidget(),
        ],
      ),
    );
  }

  /// Construye la barra de búsqueda y filtros como header sticky
  /// Comentado temporalmente para evitar problemas de renderizado
  // Widget _buildStickySearchFilter() {
  //   return const SliverToBoxAdapter(
  //     child: SearchFilterBar(),
  //   );
  // }

  /// Construye el contenido principal con manejo de estados
  Widget _buildMainContent() {
    return GetBuilder<MenuHomeCartController>(
      builder: (controller) {
        if (controller.isLoadHomeItems.value) {
          return _buildLoadingOrErrorState(controller);
        }

        return _buildContentGrid();
      },
    );
  }

  /// Construye el estado de carga o error usando EmptyStateAtom
  Widget _buildLoadingOrErrorState(MenuHomeCartController controller) {
    return ContainerAtom(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: controller.errorText.value.isEmpty
            ? const CircularProgressIndicator()
            : EmptyStateAtom(
                title: controller.errorText.value,
                titleStyle: PuTextStyle.title5,
              ),
      ),
    );
  }

  /// Construye la grilla de contenido principal
  Widget _buildContentGrid() {
    return const SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        children: [
          FilterSummaryWidget(),
          ResponsiveItemsGrid(),
        ],
      ),
    );
  }
}
