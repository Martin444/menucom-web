import 'dart:async';

/// Utility class para implementar debouncing en búsquedas
/// Evita llamadas excesivas a la API durante la escritura del usuario
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Ejecuta la función después del delay especificado
  /// Cancela las ejecuciones previas si se llama nuevamente
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancela cualquier ejecución pendiente
  void cancel() {
    _timer?.cancel();
  }

  /// Dispone del debouncer y cancela timers pendientes
  void dispose() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();
