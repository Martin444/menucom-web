// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Helper para actualizar dinámicamente los metadatos del HTML
/// Solo funciona en plataforma web
///
/// Aplica atomic design: Esta es una utilidad técnica (atom) que actualiza
/// elementos fundamentales del DOM sin lógica de negocio.
class HtmlMetadataHelper {
  /// Extrae la URL original si está usando proxy
  ///
  /// Decodifica URLs proxy como:
  /// `https://api.com/image-proxy/image?url=http%3A%2F%2Fres.cloudinary.com%2F...`
  ///
  /// Y retorna la URL original:
  /// `http://res.cloudinary.com/...`
  ///
  /// También fuerza HTTPS en las URLs decodificadas para mayor seguridad.
  static String _extractOriginalUrl(String proxyUrl) {
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
      debugPrint('[HtmlMetadataHelper] Error extracting URL: $e');
    }

    // Si no es proxy, forzar HTTPS de todas formas
    return proxyUrl.replaceFirst(RegExp(r'^http:', caseSensitive: false), 'https:');
  }

  /// Actualiza el título de la página web
  ///
  /// Ejemplo:
  /// ```dart
  /// HtmlMetadataHelper.updateTitle('Mi Comercio - MenuCom');
  /// ```
  static void updateTitle(String title) {
    html.document.title = title;
  }

  /// Actualiza el favicon de la página web
  ///
  /// [iconUrl] debe ser una URL completa o relativa a un archivo de imagen
  /// Si la URL está en formato proxy, se extrae la URL original automáticamente.
  ///
  /// Ejemplo:
  /// ```dart
  /// HtmlMetadataHelper.updateFavicon('https://example.com/logo.png');
  /// ```
  static void updateFavicon(String iconUrl) {
    // Extraer URL original si está usando proxy
    final cleanUrl = _extractOriginalUrl(iconUrl);

    // Buscar el link existente del favicon
    final existingFavicon = html.document.querySelector('link[rel="icon"]');

    if (existingFavicon != null) {
      // Actualizar el href existente
      existingFavicon.setAttribute('href', cleanUrl);
    } else {
      // Crear un nuevo elemento link si no existe
      final newFavicon = html.LinkElement()
        ..rel = 'icon'
        ..type = 'image/png'
        ..href = cleanUrl;
      html.document.head?.append(newFavicon);
    }
  }

  /// Actualiza también el apple-touch-icon para dispositivos iOS
  ///
  /// [iconUrl] debe ser una URL completa o relativa a un archivo de imagen
  /// Si la URL está en formato proxy, se extrae la URL original automáticamente.
  static void updateAppleTouchIcon(String iconUrl) {
    // Extraer URL original si está usando proxy
    final cleanUrl = _extractOriginalUrl(iconUrl);

    final existingAppleIcon = html.document.querySelector('link[rel="apple-touch-icon"]');

    if (existingAppleIcon != null) {
      existingAppleIcon.setAttribute('href', cleanUrl);
    } else {
      final newAppleIcon = html.LinkElement()
        ..rel = 'apple-touch-icon'
        ..href = cleanUrl;
      html.document.head?.append(newAppleIcon);
    }
  }

  /// Actualiza meta tags Open Graph para compartir en redes sociales
  ///
  /// Útil para mejorar el preview cuando se comparte en redes sociales
  /// Si imageUrl está en formato proxy, se extrae la URL original automáticamente.
  static void updateOpenGraphTags({
    String? title,
    String? description,
    String? imageUrl,
    String? url,
  }) {
    if (title != null) {
      _updateOrCreateMetaTag('property', 'og:title', title);
      _updateOrCreateMetaTag('name', 'twitter:title', title);
    }

    if (description != null) {
      _updateOrCreateMetaTag('property', 'og:description', description);
      _updateOrCreateMetaTag('name', 'twitter:description', description);
      _updateOrCreateMetaTag('name', 'description', description);
    }

    if (imageUrl != null) {
      // Extraer URL original si está usando proxy
      final cleanImageUrl = _extractOriginalUrl(imageUrl);
      _updateOrCreateMetaTag('property', 'og:image', cleanImageUrl);
      _updateOrCreateMetaTag('name', 'twitter:image', cleanImageUrl);
    }

    if (url != null) {
      _updateOrCreateMetaTag('property', 'og:url', url);
    }
  }

  /// Helper privado para actualizar o crear meta tags
  static void _updateOrCreateMetaTag(String attributeName, String attributeValue, String content) {
    final selector = 'meta[$attributeName="$attributeValue"]';
    final existingTag = html.document.querySelector(selector);

    if (existingTag != null) {
      existingTag.setAttribute('content', content);
    } else {
      final newTag = html.MetaElement()
        ..setAttribute(attributeName, attributeValue)
        ..content = content;
      html.document.head?.append(newTag);
    }
  }

  /// Método conveniente para actualizar todo de una vez
  ///
  /// Actualiza título, favicon, y meta tags relacionados con la información del comercio
  ///
  /// Ejemplo:
  /// ```dart
  /// HtmlMetadataHelper.updateCommerceMetadata(
  ///   name: 'Cousin Vintage',
  ///   logoUrl: 'https://example.com/logo.png',
  ///   description: 'Tienda de ropa vintage',
  /// );
  /// ```
  static void updateCommerceMetadata({
    required String name,
    String? logoUrl,
    String? description,
  }) {
    // Actualizar título
    updateTitle(name);

    // Actualizar favicon si se proporciona logo
    if (logoUrl != null && logoUrl.isNotEmpty) {
      updateFavicon(logoUrl);
      updateAppleTouchIcon(logoUrl);
    }

    // Actualizar meta tags Open Graph
    updateOpenGraphTags(
      title: name,
      description: description ?? 'Catálogo de productos',
      imageUrl: logoUrl,
      url: html.window.location.href,
    );
  }
}
