import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthController extends GetxController {
  final AuthRepositoryImpl _repository;

  AuthController(this._repository);

  Rxn<User> currentUser = Rxn<User>();
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  /// Verificar si el usuario ya está autenticado al iniciar la app
  Future<void> _checkAuthState() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          currentUser.value = user;
          // Si ya está autenticado, ir al home
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      print('Error checking auth state: $e');
    }
  }

  Future<void> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.login(email, password);
      if (user == null) {
        error.value = 'Correo o contraseña incorrectos';
      } else {
        currentUser.value = user;

        // Manejar "recordar usuario" con SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (remember) {
          await prefs.setString('remember_email', email);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('remember_email');
          await prefs.remove('remember_me');
        }

        Get.offAllNamed('/home');
      }
    } catch (e) {
      error.value = 'Error de conexión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.signUp(name, email, password);
      if (user != null) {
        // Usuario registrado exitosamente, mostrar mensaje de verificación
        Get.snackbar(
          'Registro Exitoso',
          'Se ha enviado un código de verificación a tu email',
          snackPosition: SnackPosition.TOP,
        );
        // Ir a la página de verificación de email
        Get.toNamed('/verify-email', arguments: {'email': email});
      } else {
        error.value = 'Error al registrar usuario';
      }
    } catch (e) {
      error.value = 'Error de conexión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpDirect(String name, String email, String password) async {
    isLoading.value = true;
    error.value = null;

    try {
      final user = await _repository.signUpDirect(name, email, password);
      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      } else {
        error.value = 'Error al registrar usuario';
      }
    } catch (e) {
      error.value = 'Error de conexión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    isLoading.value = true;
    error.value = null;

    try {
      final success = await _repository.verifyEmail(email, code);
      if (success) {
        Get.snackbar(
          'Email Verificado',
          'Tu cuenta ha sido activada exitosamente',
          snackPosition: SnackPosition.TOP,
        );
        // Redirigir al login
        Get.offAllNamed('/login');
      } else {
        error.value = 'Código de verificación inválido';
      }
    } catch (e) {
      error.value = 'Error de verificación: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    error.value = null;

    try {
      final success = await _repository.forgotPassword(email);
      if (success) {
        Get.snackbar(
          'Email Enviado',
          'Se ha enviado un enlace de recuperación a tu email',
          snackPosition: SnackPosition.TOP,
        );
        Get.back(); // Regresar a la pantalla anterior
      } else {
        error.value = 'Error al enviar email de recuperación';
      }
    } catch (e) {
      error.value = 'Error de conexión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    isLoading.value = true;
    error.value = null;

    try {
      final success = await _repository.resetPassword(token, newPassword);
      if (success) {
        Get.snackbar(
          'Contraseña Actualizada',
          'Tu contraseña ha sido cambiada exitosamente',
          snackPosition: SnackPosition.TOP,
        );
        Get.offAllNamed('/login');
      } else {
        error.value = 'Error al cambiar contraseña';
      }
    } catch (e) {
      error.value = 'Error de conexión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('remember_email'),
      'remember': prefs.getBool('remember_me')?.toString(),
    };
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      currentUser.value = null;

      // Limpiar SharedPreferences si es necesario
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_email');
      await prefs.remove('remember_me');

      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout: $e');
      // Aún así limpiar el estado local
      currentUser.value = null;
      Get.offAllNamed('/login');
    }
  }

  bool get isLoggedIn => currentUser.value != null;
}
