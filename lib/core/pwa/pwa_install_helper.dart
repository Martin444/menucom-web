import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' show window;

@JS('isPwaInstallAvailable')
external bool _isPwaInstallAvailable();

@JS('triggerPwaInstall')
external JSPromise<JSBoolean> _triggerPwaInstall();

class PwaInstallHelper {
  static bool get isAvailable {
    final available = _isPwaInstallAvailable();
    debugPrint('[PWA-DEBUG] PwaInstallHelper.isAvailable => $available');
    return available;
  }

  static Future<bool> triggerInstall() async {
    debugPrint('[PWA-DEBUG] PwaInstallHelper.triggerInstall called');
    try {
      final result = await _triggerPwaInstall().toDart;
      final accepted = result.toDart;
      debugPrint('[PWA-DEBUG] PwaInstallHelper.triggerInstall result: $accepted');
      return accepted;
    } catch (e) {
      debugPrint('[PWA-DEBUG] PwaInstallHelper.triggerInstall error: $e');
      return false;
    }
  }

  static void onInstallAvailable(void Function() callback) {
    debugPrint('[PWA-DEBUG] PwaInstallHelper.onInstallAvailable registering listener');
    window.addEventListener(
      'pwa-install-available',
      ((JSAny _) {
        debugPrint('[PWA-DEBUG] pwa-install-available event received in Dart');
        callback();
      }).toJS,
    );
  }

  static void onInstalled(void Function() callback) {
    debugPrint('[PWA-DEBUG] PwaInstallHelper.onInstalled registering listener');
    window.addEventListener(
      'pwa-installed',
      ((JSAny _) {
        debugPrint('[PWA-DEBUG] pwa-installed event received in Dart');
        callback();
      }).toJS,
    );
  }
}