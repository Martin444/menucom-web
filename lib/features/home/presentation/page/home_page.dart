import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_controller.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/filter_summary_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/responsive_items_grid.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/catalog_selector.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';

import '../widgets/head_home.dart';
import '../widgets/search_filter_bar.dart';

/// HomePage - Página principal del catálogo optimizada para scroll suave
///
/// Estructura:
/// 1. HeadHome (sticky header con avatar y nombre del negocio)
/// 2. Tags del catálogo + botones de acción (instalar + carrito)
/// 3. SearchFilterBar (búsqueda y filtros)
/// 4. FilterSummaryWidget (filtros activos)
/// 5. ResponsiveItemsGrid (productos)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: PUColors.primaryBackground, body: _buildMainScrollView());
  }

  /// Construye el scroll principal optimizado
  Widget _buildMainScrollView() {
    return CustomScrollView(
      slivers: [_buildHeroSliver(), _buildStickyHeaderSliver(), _buildInfoAndFiltersSliver(), _buildSliverContent()],
    );
  }

  /// Sliver para el HeroSection (no persistente) — ahora vacío para layout compacto
  Widget _buildHeroSliver() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  /// Sliver persistente para el HeadHome (vidrio líquido)
  Widget _buildStickyHeaderSliver() {
    return const SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      flexibleSpace: HeadHome(),
    );
  }

  /// Sliver para info y filtros (no persistente)
  Widget _buildInfoAndFiltersSliver() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildTagsAndActionsRow(),
          const SearchFilterBar(),
          const FilterSummaryWidget(),
        ],
      ),
    );
  }

  /// Fila compacta: tags del catálogo + botones de acción (instalar + carrito)
  Widget _buildTagsAndActionsRow() {
    return GetBuilder<HomeController>(builder: (controller) {
      return ContainerAtom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Tags del catálogo (ocupan el espacio disponible)
            const Expanded(child: CatalogSelector()),
            const SizedBox(width: 8),
            // Botón instalar PWA
            Obx(() {
              final pwaCtrl = Get.find<PwaInstallController>();
              if (!pwaCtrl.isInstallable) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PwaInstallButtonAtom(
                  onPressed: () => pwaCtrl.install(),
                  tooltip: 'Instalar aplicación',
                ),
              );
            }),
            // Botón carrito
            _buildCartButton(controller),
          ],
        ),
      );
    });
  }

  /// Icono del carrito con badge y accessibility
  Widget _buildCartButton(HomeController controller) {
    return Semantics(
      label: 'Ver carrito de compras',
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Get.toNamed(PURoutes.MYCART),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: const Alignment(0, -1.4),
              children: [
                SvgPicture.asset(
                  PUIcons.iconCart,
                  height: 36,
                  colorFilter: const ColorFilter.mode(
                    PUColors.iconColorBlack,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.fitHeight,
                ),
                // Cart badge con animación
                Positioned(
                  child: Obx(() {
                    final count = controller.cartItemCount;
                    if (count <= 0) return const SizedBox.shrink();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PUColors.restaurantPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: PuTextStyle.cartQuantityTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el contenido principal como Sliver
  Widget _buildSliverContent() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoadHomeItems) {
          return SliverToBoxAdapter(child: _buildLoadingOrErrorState(controller));
        }

        return const ResponsiveItemsGrid(isSliver: true);
      },
    );
  }

  /// Construye el estado de carga o error usando EmptyStateAtom
  Widget _buildLoadingOrErrorState(HomeController controller) {
    return ContainerAtom(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child:
            controller.errorText.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF1336E5), // Color del splash en index.html
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Preparando el catálogo...',
                      style: PuTextStyle.bodyMedium.copyWith(color: Colors.grey[600], letterSpacing: 0.5),
                    ),
                  ],
                )
                : EmptyStateAtom(title: controller.errorText, titleStyle: PuTextStyle.title5),
      ),
    );
  }
}
