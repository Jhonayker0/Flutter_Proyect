import 'package:flutter_application/data/services/auth_service.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Service
    final service = AuthService();

    // Repository
    final repo = AuthRepositoryImpl(service);

    // UseCase
    // Controller: AuthController global
    Get.put(AuthController(repo));
  }
}
