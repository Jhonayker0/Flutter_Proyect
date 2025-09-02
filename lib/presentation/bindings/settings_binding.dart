import 'package:flutter_application/presentation/theme.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Instancia inmediata del controller al iniciar la página
    Get.put(ThemeService());
    Get.put<SettingsController>(SettingsController(Get.find<ThemeService>()));
  }
}
