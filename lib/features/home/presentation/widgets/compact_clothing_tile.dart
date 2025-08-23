import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

class CompactClothingTile extends StatelessWidget {
  final ClothingItemModel item;
  final bool selected;
  final Function(ClothingItemModel) onAddCart;

  const CompactClothingTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth >= 768;
        final isDesktop = screenWidth >= 1024;

        // Responsive dimensions
        final imageSize = isDesktop ? 90.0 : (isTablet ? 85.0 : 75.0);
        final horizontalPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
        final spacing = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
        final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
        final buttonPadding = isDesktop ? 10.0 : (isTablet ? 9.0 : 8.0);
        
        // Dimensiones mínimas para evitar deformación
        final minHeight = isDesktop ? 130.0 : (isTablet ? 120.0 : 110.0);
        final minWidth = isDesktop ? 340.0 : (isTablet ? 320.0 : 300.0);

        // Responsive text scaling
        final textScaleFactor = isDesktop ? 1.1 : (isTablet ? 1.05 : 1.0);
        final smallTextScaleFactor = isDesktop ? 1.0 : (isTablet ? 0.95 : 0.9);

        return Container(
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: minWidth,
          ),
          padding: EdgeInsets.all(horizontalPadding),
          decoration: PuStyleContainers.borderAllContainer,
          child: Row(
            children: [
              // Imagen adaptativa
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PuRobustNetworkImage(
                  imageUrl: item.photoURL ?? '',
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.cover,
                  clearCacheOnError: true,
                ),
              ),

              SizedBox(width: spacing),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto - Responsive
                    Text(
                      item.name!,
                      style: PuTextStyle.nameProductStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: PuTextStyle.nameProductStyle.fontSize! * textScaleFactor,
                      ),
                      maxLines: isDesktop ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isDesktop ? 6 : 4),

                    // Marca y color - Responsive
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (item.brand != null && item.brand!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6, vertical: isDesktop ? 3 : 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.brand!,
                              style: PuTextStyle.ingredientsListStyle.copyWith(
                                color: Colors.orange[700],
                                fontSize: (isDesktop ? 12 : 11) * smallTextScaleFactor,
                              ),
                            ),
                          ),
                        if (item.color != null && item.color!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6, vertical: isDesktop ? 3 : 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.color!,
                              style: PuTextStyle.ingredientsListStyle.copyWith(
                                color: Colors.purple[700],
                                fontSize: (isDesktop ? 12 : 11) * smallTextScaleFactor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isDesktop ? 6 : 4),

                    // Tallas (si existen) - Responsive
                    if (item.sizes != null && item.sizes!.isNotEmpty)
                      PUOverflowTextDetector(
                        message: 'Tallas: ${item.sizes!.join(', ')}',
                        children: [
                          Text(
                            'Tallas: ${item.sizes!.join(', ')}',
                            style: PuTextStyle.ingredientsListStyle.copyWith(
                              fontSize: (isDesktop ? 12 : 11) * smallTextScaleFactor,
                            ),
                            maxLines: isDesktop ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                    SizedBox(height: isDesktop ? 10 : 8),

                    // Precio, cantidad y botón - Responsive
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.price!.toString().convertToCorrency(),
                                style: PuTextStyle.nameProductStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                  fontSize: PuTextStyle.nameProductStyle.fontSize! * textScaleFactor,
                                ),
                              ),
                              if (item.quantity != null && item.quantity! > 0)
                                Text(
                                  'Stock: ${item.quantity}',
                                  style: PuTextStyle.ingredientsListStyle.copyWith(
                                    fontSize: (isDesktop ? 11 : 10) * smallTextScaleFactor,
                                    color: item.quantity! > 5 ? Colors.green : Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onAddCart(item),
                          child: Container(
                            padding: EdgeInsets.all(buttonPadding),
                            decoration: BoxDecoration(
                              color: selected ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              selected ? PUIcons.iconCheck : PUIcons.iconCart,
                              height: iconSize,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
