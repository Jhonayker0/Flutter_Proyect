import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Rxn<User> currentUser = Rxn<User>();
  final isLoading = false.obs;
  final error = RxnString();

  Future<void> login(String email, String password, {bool remember = false}) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.login(email, password);
      if (user == null) {
        error.value = 'Correo o contraseña incorrectos';
      } else {
        currentUser.value = user;

        final prefs = await SharedPreferences.getInstance();
        if (remember) {
          await prefs.setString('remember_email', email);
          await prefs.setString('remember_pass', password);
        } else {
          await prefs.remove('remember_email');
          await prefs.remove('remember_pass');
        }

        Get.offAllNamed('/home');
      }
    } catch (e) {
      error.value = 'Error en login';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('remember_email'),
      'password': prefs.getString('remember_pass'),
    };
  }

  Future<void> logout() async {
    currentUser.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_email');
    await prefs.remove('remember_pass');
    Get.offAllNamed('/login');
  }

  bool get isLoggedIn => currentUser.value != null;
}







