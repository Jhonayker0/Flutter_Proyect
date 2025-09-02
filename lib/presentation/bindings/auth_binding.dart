import 'package:get/get.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Repo
    final repo = AuthRepositoryImpl();

    // Use cases
    final loginUC = LoginUseCase(repo);

    // Controller
    Get.put(AuthController(loginUseCase: loginUC));
  }
}
