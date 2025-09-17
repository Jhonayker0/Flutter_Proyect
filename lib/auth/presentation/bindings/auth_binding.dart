import 'package:flutter_application/auth/data/services/roble_auth_service.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Service - Usando el nuevo RobleAuthService
    final service = RobleAuthService();

    // Repository
    final repo = AuthRepositoryImpl(service);

    // Controller: AuthController global
    Get.put(AuthController(repo));
  }
}







