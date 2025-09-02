import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/use_cases/sign_up_case.dart';
import '../controllers/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    final repo = AuthRepositoryImpl();
    final useCase = SignUpUseCase(repo);
    Get.put(SignUpController(signUpUseCase: useCase));
  }
}
