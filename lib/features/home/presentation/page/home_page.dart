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
    // Inicializar datos del menú al construir la página usando el nuevo controlador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<HomeController>().initializeFromUrl();
    });

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: _buildMainScrollView(),
    );
  }

  /// Construye el scroll principal optimizado
  Widget _buildMainScrollView() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(),
        _buildSliverContent(),
      ],
    );
  }

  /// Construye el header como Sliver con HeroSection opcional
  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HeroSection con imagen del catálogo (si existe)
              _buildHeroSection(controller),
              
              // Header con carrito
              const HeadHome(),
              
              // Info del negocio
              const OwnerInfoWidget(),
              
              // Resumen de filtros
              const FilterSummaryWidget(),
            ],
          );
        },
      ),
    );
  }

  /// Construye el HeroSection si el catálogo tiene imagen de portada
  Widget _buildHeroSection(HomeController controller) {
    final catalog = controller.catalog;
    if (catalog == null) return const SizedBox.shrink();
    
    final coverImageUrl = catalog.coverImageUrl;
    final name = catalog.name ?? 'Catálogo';
    
    // Mostrar solo si hay imagen
    if (coverImageUrl == null || coverImageUrl.isEmpty) {
      return HeroSimpleAtom(
        title: name,
        subtitle: catalog.catalogType.capitalizeFirst ?? 'Consulta nuestro menú',
      );
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
          return SliverToBoxAdapter(
            child: _buildLoadingOrErrorState(controller),
          );
        }

        return const SliverFillRemaining(
          child: ResponsiveItemsGrid(),
        );
      },
    );
  }

  /// Construye el estado de carga o error usando EmptyStateAtom
  Widget _buildLoadingOrErrorState(HomeController controller) {
    return ContainerAtom(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: controller.errorText.isEmpty
            ? const CircularProgressIndicator(
                color: PUColors.restaurantPrimary,
              )
            : EmptyStateAtom(
                title: controller.errorText,
                titleStyle: PuTextStyle.title5,
              ),
      ),
    );
  }
}
