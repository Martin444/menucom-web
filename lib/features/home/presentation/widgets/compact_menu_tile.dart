import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';

class CompactMenuTile extends StatelessWidget {
  final MenuItemModel item;
  final bool selected;
  final Function(MenuItemModel) onAddCart;

  const CompactMenuTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  String formatDeliveryTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours h';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }

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
        final minHeight = isDesktop ? 120.0 : (isTablet ? 110.0 : 100.0);
        final minWidth = isDesktop ? 320.0 : (isTablet ? 300.0 : 280.0);

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
                  imageUrl: item.photoUrl ?? '',
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
                    PUOverflowTextDetector(
                      message: item.name!,
                      children: [
                        Text(
                          item.name!,
                          style: PuTextStyle.nameProductStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: PuTextStyle.nameProductStyle.fontSize! * textScaleFactor,
                          ),
                          maxLines: isDesktop ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    SizedBox(height: isDesktop ? 6 : 4),

                    // Tiempo de entrega - Responsive
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6, vertical: isDesktop ? 3 : 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        formatDeliveryTime(item.deliveryTime!),
                        style: PuTextStyle.ingredientsListStyle.copyWith(
                          color: Colors.blue[700],
                          fontSize: (isDesktop ? 12 : 11) * smallTextScaleFactor,
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 6 : 4),

                    // Ingredientes (si existen) - Responsive
                    if (item.ingredients != null && item.ingredients!.isNotEmpty)
                      PUOverflowTextDetector(
                        message: item.ingredients!.join(', '),
                        children: [
                          Text(
                            item.ingredients!.join(', '),
                            style: PuTextStyle.ingredientsListStyle.copyWith(
                              fontSize: (isDesktop ? 12 : 11) * smallTextScaleFactor,
                            ),
                            maxLines: isDesktop ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                    SizedBox(height: isDesktop ? 10 : 8),

                    // Precio y botón - Responsive
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.price!.toString().convertToCorrency(),
                            style: PuTextStyle.nameProductStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                              fontSize: PuTextStyle.nameProductStyle.fontSize! * textScaleFactor,
                            ),
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
