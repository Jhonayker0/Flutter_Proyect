import 'package:get/get.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Rxn<User> currentUser = Rxn<User>();
  final isLoading = false.obs;
  final error = RxnString();

  // Login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.login(email, password);
      if (user == null) {
        error.value = 'Correo o contraseña incorrectos';
      } else {
        currentUser.value = user;
        Get.offAllNamed('/home'); // navegar a home
      }
    } catch (e) {
      error.value = 'Error en login';
    } finally {
      isLoading.value = false;
    }
  }

  // SignUp
  Future<void> signUp(String name, String email, String password) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.signUp(name, email, password);
      if (user == null) {
        error.value = 'El correo ya está registrado';
      } else {
        currentUser.value = user;
        Get.offAllNamed('/home'); // navegar a home
      }
    } catch (e) {
      error.value = 'Error en registro';
    } finally {
      isLoading.value = false;
    }
  }

  // Logout global
  void logout() {
    currentUser.value = null;       // limpiar usuario en memoria
    Get.offAllNamed('/login');      // eliminar stack y navegar a login
  }

  bool get isLoggedIn => currentUser.value != null;
}
