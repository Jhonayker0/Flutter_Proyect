import 'package:get/get.dart';
import '../../../domain/use_cases/sign_up_case.dart';
import '../../../routes.dart';

class SignUpController extends GetxController {
  final SignUpUseCase signUpUseCase;
  SignUpController({required this.signUpUseCase});

  var loading = false.obs;
  var error = ''.obs;

  Future<void> signUp(String name, String email, String password) async {
    loading.value = true;
    error.value = '';

    final success = await signUpUseCase.execute(name, email, password);

    if (success) {
      Get.offAllNamed(Routes.home);
    } else {
      error.value = 'Ese correo ya está registrado';
    }

    loading.value = false;
  }
}
