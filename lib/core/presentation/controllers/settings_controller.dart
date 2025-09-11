import 'package:flutter_application/core/data/datasources/borrar.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_application/core/presentation/theme/theme.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Si quieres manejar estado o acciones como cerrar sesión

  final ThemeService themeService;
  SettingsController(this.themeService);

  bool get isDark => themeService.isDark;

  Future<void> toggleTheme() => themeService.toggleTheme();
  
  void selectOption(String title) {
    if (title == "Cerrar sesión") {
      final authController = Get.find<AuthController>();
      authController.logout(); 
    } 
    else {
      deleteDatabaseFile();
    }
  }
}







