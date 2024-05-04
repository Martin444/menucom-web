import 'package:intl/intl.dart';

extension PUStringFormater on String {
  String convertToCorrency() {
    final originalValue = double.tryParse(this);
    if (originalValue == null) {
      return '\$${0.00}';
      // return 'Error: Valor no válido';
    }

    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2, // Dos decimales
      locale: 'es_AR', // Cambia a tu localización deseada
    );

    final formattedValue = formatter.format(originalValue);
    return '\$$formattedValue';
  }
}
