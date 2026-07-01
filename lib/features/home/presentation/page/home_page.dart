import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_controller.dart';
import 'package:menucom_catalog/features/home/controllers/catalog_controller.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/filter_summary_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/responsive_items_grid.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/catalog_selector.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/desktop_filter_sidebar.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';

import '../widgets/head_home.dart';
import '../widgets/search_filter_bar.dart';

/// HomePage - Página principal del catálogo optimizada para scroll suave
///
/// Layout responsive:
/// - Desktop (>= 900px): sidebar de filtros a la izquierda + grid de productos
/// - Mobile (< 900px): filtros arriba + grid de productos (scroll vertical)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
          if (isDesktop) {
            return _buildDesktopLayout(constraints);
          }
          return _buildMobileLayout();
        },
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Column(
      children: [
        // Header fijo arriba
        const _DesktopHeader(),
        // Contenido: sidebar + grid
        Expanded(
          child: Row(
            children: [
              // Sidebar de filtros
              const DesktopFilterSidebar(),
              // Área de productos
              Expanded(
                child: _buildDesktopContentArea(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContentArea() {
    return GetBuilder<CatalogController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _buildLoadingOrErrorState(controller);
        }

        return CustomScrollView(
          slivers: [
            _buildDesktopTagsAndActions(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const ResponsiveItemsGrid(isSliver: true),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTagsAndActions() {
    return SliverToBoxAdapter(
      child: _buildTagsAndActionsRow(),
    );
  }

  // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildHeroSliver(),
        _buildStickyHeaderSliver(),
        _buildInfoAndFiltersSliver(),
        _buildSliverContent(),
      ],
    );
  }

  Widget _buildHeroSliver() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

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

  Widget _buildSliverContent() {
    return GetBuilder<CatalogController>(
      builder: (controller) {
        if (controller.isLoading) {
          return SliverToBoxAdapter(child: _buildLoadingOrErrorState(controller));
        }

        return const ResponsiveItemsGrid(isSliver: true);
      },
    );
  }

  // ==================== SHARED WIDGETS ====================

  Widget _buildTagsAndActionsRow() {
    return ContainerAtom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(child: CatalogSelector()),
          const SizedBox(width: 8),
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
          _buildCartButton(),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
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
                Positioned(
                  child: Obx(() {
                    final count = Get.find<CartController>().itemCount;
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

  Widget _buildLoadingOrErrorState(CatalogController controller) {
    return ContainerAtom(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: controller.error.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF1336E5),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Preparando el catálogo...',
                    style: PuTextStyle.bodyMedium.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            : EmptyStateAtom(
                title: controller.error,
                titleStyle: PuTextStyle.title5,
              ),
      ),
    );
  }
}

/// Header para desktop: combina HeadHome + tags + acciones en una sola barra
class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: const HeadHome(),
    );
  }
}
