import 'package:flutter_application/data/services/auth_service.dart';
import 'package:flutter_application/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/use_cases/sign_up_case.dart';
import '../controllers/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Repositorio y UseCase
    final service = AuthService();
    final repo = AuthRepositoryImpl(service);
    final useCase = SignUpUseCase(repo);

    // Obtén el AuthController ya registrado
    final authController = Get.find<AuthController>();

    // Inyecta el SignUpController con useCase + authController
    Get.put(SignUpController(
      signUpUseCase: useCase,
      authController: authController,
    ));
  }
}
