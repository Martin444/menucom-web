import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_helper.dart';
import 'package:web/web.dart';

class PwaInstallController extends GetxController {
  final RxBool _isInstallable = false.obs;

  late final JSFunction _onAvailableHandler;
  late final JSFunction _onInstalledHandler;

  bool get isInstallable => _isInstallable.value;
  RxBool get isInstallableRx => _isInstallable;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[PWA-DEBUG] PwaInstallController.onInit');
    _checkInitialState();
    _setupListeners();
  }

  @override
  void onClose() {
    debugPrint('[PWA-DEBUG] PwaInstallController.onClose');
    window.removeEventListener('pwa-install-available', _onAvailableHandler);
    window.removeEventListener('pwa-installed', _onInstalledHandler);
    super.onClose();
  }

  void _checkInitialState() {
    debugPrint('[PWA-DEBUG] _checkInitialState');
    _isInstallable.value = PwaInstallHelper.isAvailable;
    debugPrint('[PWA-DEBUG] _checkInitialState isInstallable: ${_isInstallable.value}');
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isInstallable.value) {
        _isInstallable.value = PwaInstallHelper.isAvailable;
        debugPrint('[PWA-DEBUG] _checkInitialState delayed retry isInstallable: ${_isInstallable.value}');
      }
    });
  }

  void _setupListeners() {
    debugPrint('[PWA-DEBUG] _setupListeners');
    _onAvailableHandler = ((JSAny _) {
      debugPrint('[PWA-DEBUG] pwa-install-available handler fired in controller');
      _isInstallable.value = true;
    }).toJS;

    _onInstalledHandler = ((JSAny _) {
      debugPrint('[PWA-DEBUG] pwa-installed handler fired in controller');
      _isInstallable.value = false;
    }).toJS;

    window.addEventListener('pwa-install-available', _onAvailableHandler);
    window.addEventListener('pwa-installed', _onInstalledHandler);
  }

  Future<void> install() async {
    debugPrint('[PWA-DEBUG] PwaInstallController.install called, isInstallable: ${_isInstallable.value}');
    final success = await PwaInstallHelper.triggerInstall();
    debugPrint('[PWA-DEBUG] PwaInstallController.install result: $success');
    if (success) {
      _isInstallable.value = false;
    }
  }
}