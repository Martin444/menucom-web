import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_controller.dart';
import 'package:menucom_catalog/features/home/controllers/catalog_controller.dart';
import 'package:menucom_catalog/features/home/controllers/cart_controller.dart';
import 'package:menucom_catalog/features/home/controllers/filter_controller.dart';
import 'package:menucom_catalog/features/home/controllers/home_controller.dart';
import 'package:menucom_catalog/features/home/ui/molecules/filter_summary_molecule.dart';
import 'package:menucom_catalog/features/home/ui/organisms/business_profile_footer_organism.dart';
import 'package:menucom_catalog/features/home/ui/organisms/catalog_selector_organism.dart';
import 'package:menucom_catalog/features/home/ui/organisms/desktop_filter_sidebar_organism.dart';
import 'package:menucom_catalog/features/home/ui/organisms/head_home_organism.dart';
import 'package:menucom_catalog/features/home/ui/organisms/responsive_items_grid_organism.dart';
import 'package:menucom_catalog/features/home/ui/organisms/search_filter_bar_organism.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const double desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= desktopBreakpoint) return _desktopLayout();
          return _mobileLayout();
        },
      ),
    );
  }

  Widget _desktopLayout() {
    return Column(children: [
      _desktopHeader(),
      Expanded(child: Row(children: [_desktopSidebar(), Expanded(child: _desktopContent())])),
    ]);
  }

  Widget _desktopHeader() {
    return Obx(() {
      final cat = Get.find<CatalogController>().catalogResponse;
      return Container(
        decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)))),
        child: HeadHomeOrganism(
          commerceName: cat?.commerce?['name']?.toString() ?? cat?.owner?['name']?.toString() ?? cat?.name ?? '',
          commerceLogoUrl: cat?.commerce?['logoUrl']?.toString() ?? cat?.owner?['photoURL']?.toString(),
        ),
      );
    });
  }

  Widget _desktopSidebar() {
    return GetBuilder<FilterController>(builder: (f) => DesktopFilterSidebarOrganism(
      searchQuery: f.searchQuery, sortBy: f.sortBy,
      availableCategories: f.availableCategories, selectedCategories: f.selectedCategories,
      showOnlyAvailable: f.showOnlyAvailable, showOnlyOnSale: f.showOnlyOnSale, showOnlyFeatured: f.showOnlyFeatured,
      minPrice: f.minPrice, maxPrice: f.maxPrice, priceUpperBound: f.priceUpperBound,
      totalFilteredItems: f.sortedFilteredItems.length,
      onSearchChanged: (v) => f.updateSearchQuery(v), onSortChanged: (v) => f.setSortBy(v),
      onCategoryToggled: (v) => f.toggleCategory(v),
      onAvailableToggled: () => f.toggleAvailableOnly(), onSaleToggled: () => f.toggleOnSale(), onFeaturedToggled: () => f.toggleFeatured(),
      onPriceRangeChanged: (a, b) => f.setPriceRange(a, b), onClearFilters: () => f.clearFilters(),
    ));
  }

  Widget _desktopContent() {
    return Obx(() {
      final c = Get.find<CatalogController>();
      if (c.isLoading) return _loadingState(c.error);
      return NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: CustomScrollView(slivers: [_buildProfileSliver(), _desktopTopBar(), const SliverToBoxAdapter(child: SizedBox(height: 8)), const _ProductsGridWidget(isSliver: true)]),
      );
    });
  }

  Widget _desktopTopBar() {
    return SliverToBoxAdapter(child: GetBuilder<HomeController>(builder: (h) => ContainerAtom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Expanded(child: h.hasMultipleCatalogs ? CatalogSelectorOrganism(catalogs: h.catalogs, selectedCatalogIndex: h.selectedCatalogIndex, onCatalogSelected: (i) => h.selectCatalog(i)) : const SizedBox.shrink()),
        const SizedBox(width: 8),
        const _CartButtonWidget(),
      ]),
    )));
  }

  // ── Mobile ──

  Widget _mobileLayout() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(slivers: [_mobileHeader(), _buildProfileSliver(), _mobileInfoAndFilters(), _mobileContent()]),
    );
  }

  Widget _mobileHeader() {
    return Obx(() {
      final cat = Get.find<CatalogController>().catalogResponse;
      return SliverAppBar(
        pinned: true, floating: true, elevation: 0, backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, toolbarHeight: 70,
        flexibleSpace: HeadHomeOrganism(
          commerceName: cat?.commerce?['name']?.toString() ?? cat?.owner?['name']?.toString() ?? cat?.name ?? '',
          commerceLogoUrl: cat?.commerce?['logoUrl']?.toString() ?? cat?.owner?['photoURL']?.toString(),
        ),
      );
    });
  }

  Widget _mobileInfoAndFilters() {
    return SliverToBoxAdapter(child: Column(children: [
      GetBuilder<HomeController>(builder: (h) => ContainerAtom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: CatalogSelectorOrganism(catalogs: h.catalogs, selectedCatalogIndex: h.selectedCatalogIndex, onCatalogSelected: (i) => h.selectCatalog(i))),
          const SizedBox(width: 8),
          Obx(() => Get.find<PwaInstallController>().isInstallable ? Padding(padding: const EdgeInsets.only(right: 8), child: PwaInstallButtonAtom(onPressed: () => Get.find<PwaInstallController>().install(), tooltip: 'Instalar aplicacion')) : const SizedBox.shrink()),
          const _CartButtonWidget(),
        ]),
      )),
      GetBuilder<FilterController>(builder: (f) => SearchFilterBarOrganism(
        searchQuery: f.searchQuery, sortBy: f.sortBy,
        availableCategories: f.availableCategories, selectedCategories: f.selectedCategories,
        showOnlyAvailable: f.showOnlyAvailable, showOnlyOnSale: f.showOnlyOnSale, showOnlyFeatured: f.showOnlyFeatured,
        minPrice: f.minPrice, maxPrice: f.maxPrice, priceUpperBound: f.priceUpperBound,
        onSearchChanged: (v) => f.updateSearchQuery(v), onSortChanged: (v) => f.setSortBy(v),
        onCategoryToggled: (v) => f.toggleCategory(v),
        onAvailableToggled: () => f.toggleAvailableOnly(), onSaleToggled: () => f.toggleOnSale(), onFeaturedToggled: () => f.toggleFeatured(),
        onPriceRangeChanged: (a, b) => f.setPriceRange(a, b),
      )),
      GetBuilder<FilterController>(builder: (f) => FilterSummaryMolecule(
        totalItems: f.sortedFilteredItems.length, searchQuery: f.searchQuery,
        selectedCategories: f.selectedCategories, showOnlyAvailable: f.showOnlyAvailable,
        showOnlyOnSale: f.showOnlyOnSale, showOnlyFeatured: f.showOnlyFeatured,
        minPrice: f.minPrice, maxPrice: f.maxPrice, priceUpperBound: f.priceUpperBound,
        onClearFilters: () => f.clearFilters(),
      )),
    ]));
  }

  Widget _mobileContent() {
    return Obx(() {
      final c = Get.find<CatalogController>();
      if (c.isLoading) return SliverToBoxAdapter(child: _loadingState(c.error));
      return const SliverToBoxAdapter(child: _ProductsGridWidget(isSliver: false));
    });
  }

  // ── Shared ──

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent > 0 && metrics.pixels >= metrics.maxScrollExtent * 0.8) {
        final home = Get.find<HomeController>();
        if (home.hasMoreItems && !home.isLoadingMore) {
          home.loadMoreItems();
        }
      }
    }
    return false;
  }

  Widget _buildProfileSliver() {
    return GetBuilder<HomeController>(
      builder: (home) {
        if (home.businessProfile == null) return const SliverToBoxAdapter();
        return SliverToBoxAdapter(child: BusinessProfileFooterOrganism(
          profile: home.businessProfile!,
          commerceName: home.nameComerce,
          commerceLogoUrl: home.ownerPhotoUrl,
          isHeader: true,
        ));
      },
    );
  }

  Widget _loadingState(String error) {
    return ContainerAtom(height: 400, padding: const EdgeInsets.symmetric(horizontal: 20), child: Center(
      child: error.isEmpty
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(color: Color(0xFF1336E5), strokeWidth: 3), const SizedBox(height: 20), Text('Preparando el catalogo...', style: PuTextStyle.bodyMedium.copyWith(color: Colors.grey[600], letterSpacing: 0.5))])
          : EmptyStateAtom(title: error, titleStyle: PuTextStyle.title5),
    ));
  }
}

/// Widget propio para el botón de carrito — reemplaza la función _cartButton()
class _CartButtonWidget extends StatelessWidget {
  const _CartButtonWidget();

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: const Alignment(0, -1.4),
              children: [
                SvgPicture.asset(PUIcons.iconCart, height: 36, colorFilter: const ColorFilter.mode(PUColors.iconColorBlack, BlendMode.srcIn), fit: BoxFit.fitHeight),
                Positioned(
                  child: Obx(() {
                    final count = Get.find<CartController>().itemCount;
                    if (count <= 0) return const SizedBox.shrink();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: PUColors.restaurantPrimary, borderRadius: BorderRadius.circular(10)),
                      child: Text(count.toString(), style: PuTextStyle.cartQuantityTextStyle.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
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
}

/// Widget propio para la grilla reactiva de productos — reemplaza la función _buildGrid()
class _ProductsGridWidget extends StatelessWidget {
  final bool isSliver;
  const _ProductsGridWidget({required this.isSliver});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (f) {
      final cat = Get.find<CatalogController>();
      final home = Get.find<HomeController>();
      return GetBuilder<CartController>(builder: (cart) {
        return ResponsiveItemsGridOrganism(
          items: f.displayedItems,
          isLoadingMore: home.isLoadingMore,
          catalogType: cat.catalogResponse?.catalogType ?? 'wardrobe',
          onItemTap: (item) => Get.toNamed('/product-detail', arguments: {
            'item': item, 'isAdded': cart.containsItem(item.id),
            'onAddCart': (CatalogItemModel i) => cart.toggleItem(i),
            'name': item.name, 'description': item.description,
            'photoUrl': item.photoURL, 'price': item.price.toString(),
          }),
          isItemAdded: (id) => cart.containsItem(id),
          onAddToCart: (item) => cart.toggleItem(item),
          isSliver: isSliver,
        );
      });
    });
  }
}
