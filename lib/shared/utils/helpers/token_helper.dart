import 'dart:convert';
import 'package:flutter/material.dart';

/// Codifica el accessToken usando base64Url (no es cifrado, solo encoding)
String hashAccessToken(String accessToken) {
  final encoded = base64Url.encode(utf8.encode(accessToken));
  debugPrint('[hashAccessToken] base64Url: $encoded');
  return encoded;
}

String decryptAccessToken(String encodedToken) {
  try {
    final decoded = utf8.decode(base64Url.decode(encodedToken));
    return decoded;
  } catch (e, stack) {
    debugPrint('[decryptAccessToken] Error al decodificar: $e');
    debugPrint('[decryptAccessToken] Stacktrace: $stack');
    return '';
  }
}
