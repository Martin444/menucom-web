// Test manual para verificar la extracción de URLs proxy
// Este archivo es solo para documentación y testing manual

void main() {
  print('=== Test de extracción de URLs proxy ===\n');

  // Caso 1: URL con proxy
  const proxyUrl =
      'https://menucom-api-60e608ae2f99.herokuapp.com/api/image-proxy/image?url=http%3A%2F%2Fres.cloudinary.com%2Fphotographer%2Fimage%2Fupload%2Fv1757809490%2Fo5ijxvu14ir4zvm3ny7s.png';
  final extractedUrl1 = extractOriginalUrl(proxyUrl);
  print('✅ Caso 1 - URL con proxy:');
  print('   Input:  $proxyUrl');
  print('   Output: $extractedUrl1');
  print('   Esperado: https://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png\n');

  // Caso 2: URL sin proxy (HTTP)
  const httpUrl = 'http://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png';
  final extractedUrl2 = extractOriginalUrl(httpUrl);
  print('✅ Caso 2 - URL sin proxy (HTTP → HTTPS):');
  print('   Input:  $httpUrl');
  print('   Output: $extractedUrl2');
  print('   Esperado: https://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png\n');

  // Caso 3: URL sin proxy (HTTPS)
  const httpsUrl = 'https://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png';
  final extractedUrl3 = extractOriginalUrl(httpsUrl);
  print('✅ Caso 3 - URL sin proxy (HTTPS):');
  print('   Input:  $httpsUrl');
  print('   Output: $extractedUrl3');
  print('   Esperado: https://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png\n');

  // Caso 4: URL vacía
  const emptyUrl = '';
  final extractedUrl4 = extractOriginalUrl(emptyUrl);
  print('✅ Caso 4 - URL vacía:');
  print('   Input:  "$emptyUrl"');
  print('   Output: "$extractedUrl4"');
  print('   Esperado: ""\n');
}

/// Extrae la URL original si está usando proxy
String extractOriginalUrl(String proxyUrl) {
  if (proxyUrl.isEmpty) return proxyUrl;

  try {
    final uri = Uri.parse(proxyUrl);

    // Si tiene parámetro 'url', extraerlo y decodificarlo
    if (uri.queryParameters.containsKey('url')) {
      String originalUrl = Uri.decodeComponent(uri.queryParameters['url']!);

      // Forzar HTTPS para seguridad (los favicons con HTTP pueden no cargar)
      originalUrl = originalUrl.replaceFirst(RegExp(r'^http:', caseSensitive: false), 'https:');

      return originalUrl;
    }
  } catch (e) {
    // Si hay error al parsear, devolver la URL original
    print('[Error] Error extracting URL: $e');
  }

  // Si no es proxy, forzar HTTPS de todas formas
  return proxyUrl.replaceFirst(RegExp(r'^http:', caseSensitive: false), 'https:');
}
