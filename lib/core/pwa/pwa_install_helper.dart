// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PwaInstallHelper {
  static bool get isAvailable {
    final result = js.context.callMethod('isPwaInstallAvailable', []);
    return result == true;
  }

  static Future<bool> triggerInstall() async {
    final result = await js.context.callMethod('triggerPwaInstall', []);
    return result == true;
  }

  static void onInstallAvailable(void Function() callback) {
    html.window.addEventListener('pwa-install-available', (_) => callback());
  }

  static void onInstalled(void Function() callback) {
    html.window.addEventListener('pwa-installed', (_) => callback());
  }
}
