import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../services/roble_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RobleAuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<User?> login(String email, String password) async {
    try {
      return await _service.login(email, password);
    } catch (e) {
      print('Repository login error: $e');
      return null;
    }
  }

  @override
  Future<User?> signUp(String name, String email, String password) async {
    try {
      // Usar signup normal (requiere verificación de email)
      final success = await _service.signup(email, password, name);
      
      if (success) {
        // El usuario fue registrado pero necesita verificar email
        // Retornamos un usuario temporal para mostrar el flujo de verificación
        return User(
          id: 0, // ID temporal
          name: name,
          email: email,
          imagepathh: null,
        );
      }
    } catch (e) {
      print('Repository signup error: $e');
    }
    return null;
  }

  // Nuevos métodos para las funcionalidades de ROBLE
  Future<User?> signUpDirect(String name, String email, String password) async {
    try {
      final success = await _service.signupDirect(email, password, name);
      
      if (success) {
        // Para signup directo, intentamos hacer login inmediatamente
        return await login(email, password);
      }
    } catch (e) {
      print('Repository signupDirect error: $e');
    }
    return null;
  }

  Future<bool> verifyEmail(String email, String code) async {
    try {
      return await _service.verifyEmail(email, code);
    } catch (e) {
      print('Repository verifyEmail error: $e');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      return await _service.forgotPassword(email);
    } catch (e) {
      print('Repository forgotPassword error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      return await _service.resetPassword(token, newPassword);
    } catch (e) {
      print('Repository resetPassword error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      return await _service.logout();
    } catch (e) {
      print('Repository logout error: $e');
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      return await _service.isAuthenticated();
    } catch (e) {
      print('Repository isAuthenticated error: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return await _service.getUserInfo();
    } catch (e) {
      print('Repository getCurrentUser error: $e');
      return null;
    }
  }
}







