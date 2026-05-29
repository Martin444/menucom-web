import 'dart:js_interop';

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
    _checkInitialState();
    _setupListeners();
  }

  @override
  void onClose() {
    window.removeEventListener('pwa-install-available', _onAvailableHandler);
    window.removeEventListener('pwa-installed', _onInstalledHandler);
    super.onClose();
  }

  void _checkInitialState() {
    _isInstallable.value = PwaInstallHelper.isAvailable;
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isInstallable.value) {
        _isInstallable.value = PwaInstallHelper.isAvailable;
      }
    });
  }

  void _setupListeners() {
    _onAvailableHandler = ((JSAny _) {
      _isInstallable.value = true;
    }).toJS;

    _onInstalledHandler = ((JSAny _) {
      _isInstallable.value = false;
    }).toJS;

    window.addEventListener('pwa-install-available', _onAvailableHandler);
    window.addEventListener('pwa-installed', _onInstalledHandler);
  }

  Future<void> install() async {
    final success = await PwaInstallHelper.triggerInstall();
    if (success) {
      _isInstallable.value = false;
    }
  }
}
