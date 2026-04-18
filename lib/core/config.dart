// ignore_for_file: non_constant_identifier_names, constant_identifier_names
const String ACCESS_TOKEN_SECRET_KEY = String.fromEnvironment(
  'ACCESS_TOKEN_SECRET_KEY',
  defaultValue: "",
);

const String URL_PICKME_API = String.fromEnvironment('API_URL', defaultValue: "");

// MercadoPago Public Key (solo frontend). Configurable por --dart-define=MP_PUBLIC_KEY=...
const String MP_PUBLIC_KEY = String.fromEnvironment('MP_PUBLIC_KEY', defaultValue: "");
// Locale opcional para MercadoPago (ej: es-AR, es-MX, pt-BR)
const String MP_LOCALE = String.fromEnvironment('MP_LOCALE', defaultValue: "es-AR");

class AppConfig {
  static String get webSocketUrl => const String.fromEnvironment('WS_URL', defaultValue: 'https://api.menucom.com');
}

String ACCESS_TOKEN = '';
String NAME_USER = '';
