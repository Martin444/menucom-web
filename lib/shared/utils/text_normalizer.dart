/// Utility class para normalización de texto en búsquedas
/// Proporciona métodos para normalizar texto y mejorar resultados de búsqueda
class TextNormalizer {
  /// Normaliza un string removiendo acentos y convirtiendo a minúsculas
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .trim();
  }

  /// Verifica si una query es numérica
  static bool isNumeric(String query) {
    return double.tryParse(query) != null;
  }

  /// Normaliza una lista de strings
  static List<String> normalizeList(List<String> texts) {
    return texts.map(normalize).toList();
  }

  /// Verifica si el texto contiene la query normalizada
  static bool contains(String text, String query) {
    return normalize(text).contains(normalize(query));
  }

  /// Verifica si algún elemento de la lista contiene la query
  static bool containsInList(List<String> texts, String query) {
    final normalizedQuery = normalize(query);
    return texts.any((text) => normalize(text).contains(normalizedQuery));
  }
}
