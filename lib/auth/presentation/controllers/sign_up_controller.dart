import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_application/auth/domain/use_cases/sign_up_case.dart';
import 'package:flutter_application/routes.dart';
import 'package:flutter_application/auth/domain/models/user.dart';

class SignUpController extends GetxController {
  final SignUpUseCase signUpUseCase;
  final AuthController authController;

  SignUpController({required this.signUpUseCase, required this.authController});

  var loading = false.obs;
  var error = ''.obs;

  Future<void> signUp(String name, String email, String password) async {
    loading.value = true;
    error.value = '';

    // Ejecuta el use case, devuelve un User? en vez de bool
    final User? user = await signUpUseCase.execute(name, email, password);

    if (user != null) {
      // guarda el usuario logueado
      Get.offAllNamed(Routes.login); // navega a Home
    } else {
      error.value = 'Ese correo ya está registrado';
    }

    loading.value = false;
  }
}
