class ImageUrlService {
  static const String proxyBaseUrl = 'http://localhost:3000/api/image-proxy/image';

  /// Construye una URL de imagen con proxy
  static String buildProxyUrl(String originalUrl) {
    if (originalUrl.isEmpty) return originalUrl;

    // Si ya es una URL de proxy, no hacemos nada
    if (originalUrl.contains('/api/image-proxy/')) {
      return originalUrl;
    }

    // Codificar la URL original
    final encodedUrl = Uri.encodeComponent(originalUrl);

    return '$proxyBaseUrl?url=$encodedUrl';
  }

  /// Extrae la URL original de una URL de proxy
  static String extractOriginalUrl(String proxyUrl) {
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

  /// Obtiene las posibles URLs para intentar cargar (con fallbacks)
  static List<String> getPossibleUrls(String imageUrl) {
    if (imageUrl.isEmpty) return [];

    final urls = <String>[];

    // Si es una URL de proxy, intentar tanto proxy como original
    if (imageUrl.contains('/api/image-proxy/')) {
      urls.add(imageUrl); // URL de proxy
      final originalUrl = extractOriginalUrl(imageUrl);
      if (originalUrl != imageUrl) {
        urls.add(originalUrl); // URL original
      }
    } else {
      // Si es una URL normal, intentar primero con proxy, luego sin proxy
      urls.add(buildProxyUrl(imageUrl)); // Con proxy
      urls.add(imageUrl); // Sin proxy
    }

    return urls;
  }
}
