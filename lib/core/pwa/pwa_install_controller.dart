import 'package:get/get.dart';
import 'package:menucom_catalog/core/pwa/pwa_install_helper.dart';

class PwaInstallController extends GetxController {
  final RxBool _isInstallable = false.obs;

  bool get isInstallable => _isInstallable.value;
  RxBool get isInstallableRx => _isInstallable;

  @override
  void onInit() {
    super.onInit();
    _checkInitialState();
    _setupListeners();
  }

  void _checkInitialState() {
    _isInstallable.value = PwaInstallHelper.isAvailable;
  }

  void _setupListeners() {
    PwaInstallHelper.onInstallAvailable(() {
      _isInstallable.value = true;
    });
    PwaInstallHelper.onInstalled(() {
      _isInstallable.value = false;
    });
  }

  Future<void> install() async {
    final success = await PwaInstallHelper.triggerInstall();
    if (success) {
      _isInstallable.value = false;
    }
  }
}
