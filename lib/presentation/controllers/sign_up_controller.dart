import 'package:flutter_application/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../../domain/use_cases/sign_up_case.dart';
import '../../../routes.dart';
import '../../../domain/models/user.dart';

class SignUpController extends GetxController {
  final SignUpUseCase signUpUseCase;
  final AuthController authController;

  SignUpController({
    required this.signUpUseCase,
    required this.authController,
  });

  var loading = false.obs;
  var error = ''.obs;

  Future<void> signUp(String name, String email, String password) async {
    loading.value = true;
    error.value = '';

    final User? user = await signUpUseCase.execute(name, email, password);

    if (user != null) {
      authController.currentUser.value = user;  // guarda el usuario logueado
      Get.offAllNamed(Routes.home);             // navega a Home
    } else {
      error.value = 'Ese correo ya está registrado';
    }

    loading.value = false;
  }
}
