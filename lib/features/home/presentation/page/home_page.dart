import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/owner_info_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/filter_summary_widget.dart';
import 'package:menucom_catalog/features/home/presentation/widgets/responsive_items_grid.dart';
import 'package:pu_material/pu_material.dart';

import '../widgets/head_home.dart';

/// HomePage - Página principal del catálogo optimizada para scroll suave
///
/// Estructura:
/// 1. HeroSection (banner si hay imagen)
/// 2. HeadHome (header con carrito)
/// 3. OwnerInfoWidget (info del negocio)
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

  /// Sliver para el HeroSection (no persistente)
  Widget _buildHeroSliver() {
    return SliverToBoxAdapter(
      child: GetBuilder<HomeController>(builder: (controller) => _buildHeroSection(controller)),
    );
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
    return SliverToBoxAdapter(child: Column(children: const [OwnerInfoWidget(), FilterSummaryWidget()]));
  }

  /// Construye el HeroSection si el catálogo tiene imagen de portada
  Widget _buildHeroSection(HomeController controller) {
    final catalog = controller.catalog;
    if (catalog == null) return const SizedBox.shrink();

    final coverImageUrl = catalog.coverImageUrl;
    final name = catalog.name ?? 'Catálogo';

    // Mostrar solo si hay imagen
    if (coverImageUrl == null || coverImageUrl.isEmpty) {
      return HeroSimpleAtom(title: name, subtitle: catalog.catalogType.capitalizeFirst ?? 'Consulta nuestro menú');
    }

    return HeroSectionAtom(
      title: name,
      subtitle: catalog.catalogType.capitalizeFirst ?? 'Consulta nuestro menú',
      imageUrl: coverImageUrl,
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
