import 'package:flutter_application/presentation/theme.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Si quieres manejar estado o acciones como cerrar sesión

  final ThemeService themeService;
  SettingsController(this.themeService);

  bool get isDark => themeService.isDark;

  Future<void> toggleTheme() => themeService.toggleTheme();
  
  void selectOption(String title) {
    if (title == "Cerrar sesión") {
      Get.offAllNamed('/login'); // navegar a login y limpiar stack
    } else {
      Get.snackbar("Opción seleccionada", title,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
