import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RobustNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const RobustNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar si la URL es válida
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWithFallback(url, error),
      httpHeaders: const {
        'User-Agent': 'Flutter App',
      },
      // Configuración para manejar CORS y problemas de conectividad
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 50,
          ),
        );
  }

  Widget _buildErrorWithFallback(String url, dynamic error) {
    print('Error loading image: $url - Error: $error');

    // Extraer URL original si está usando proxy
    String originalUrl = _extractOriginalUrl(url);

    // Si tenemos una URL diferente (sin proxy), intentar cargarla
    if (originalUrl != url) {
      return Image.network(
        originalUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error2, stackTrace2) {
          return _buildErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
      );
    }

    return _buildErrorWidget();
  }

  // Extraer la URL original si está usando proxy
  String _extractOriginalUrl(String proxyUrl) {
    try {
      final uri = Uri.parse(proxyUrl);
      if (uri.queryParameters.containsKey('url')) {
        return Uri.decodeComponent(uri.queryParameters['url']!);
      }
    } catch (e) {
      print('Error extracting original URL: $e');
    }
    return proxyUrl;
  }
}
