import 'dart:js_interop';

import 'package:web/web.dart' show window;

@JS('isPwaInstallAvailable')
external bool _isPwaInstallAvailable();

@JS('triggerPwaInstall')
external JSPromise<JSBoolean> _triggerPwaInstall();

class PwaInstallHelper {
  static bool get isAvailable {
    return _isPwaInstallAvailable();
  }

  static Future<bool> triggerInstall() async {
    final result = await _triggerPwaInstall().toDart;
    return result.toDart;
  }

  static void onInstallAvailable(void Function() callback) {
    window.addEventListener(
      'pwa-install-available',
      ((JSAny _) => callback()).toJS,
    );
  }

  static void onInstalled(void Function() callback) {
    window.addEventListener(
      'pwa-installed',
      ((JSAny _) => callback()).toJS,
    );
  }
}
