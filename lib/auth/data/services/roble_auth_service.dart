import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/auth/domain/models/auth_models.dart';
import 'package:flutter_application/auth/domain/models/user.dart';

class RobleAuthService {
  final RobleHttpService _httpService = RobleHttpService();

  /// Autenticar usuario con email y contraseña
  Future<User?> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email.trim(), password: password);
      final tokens = await _httpService.login(request);
      
      if (tokens != null) {
        // Después del login exitoso, obtener la información del usuario
        final userInfo = await getUserInfo();
        return userInfo;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Registrar nuevo usuario (requiere verificación de email)
  Future<bool> signup(String email, String password, String name) async {
    try {
      final request = SignupRequest(
        email: email.trim(), 
        password: password, 
        name: name.trim(),
      );
      return await _httpService.signup(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Registrar usuario directamente (sin verificación de email)
  Future<bool> signupDirect(String email, String password, String name) async {
    try {
      final request = SignupRequest(
        email: email.trim(), 
        password: password, 
        name: name.trim(),
      );
      return await _httpService.signupDirect(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar email con código
  Future<bool> verifyEmail(String email, String code) async {
    try {
      final request = VerifyEmailRequest(email: email.trim(), code: code);
      return await _httpService.verifyEmail(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Solicitar recuperación de contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email.trim());
      return await _httpService.forgotPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Restablecer contraseña con token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final request = ResetPasswordRequest(token: token, newPassword: newPassword);
      return await _httpService.resetPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<bool> logout() async {
    try {
      return await _httpService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Limpiar tokens localmente aunque falle
      await _httpService.clearTokens();
      return true;
    }
  }

  /// Verificar si el token actual es válido
  Future<bool> isTokenValid() async {
    try {
      return await _httpService.verifyToken();
    } catch (e) {
      return false;
    }
  }

  /// Obtener información del usuario autenticado
  /// Nota: Este método necesitará ser implementado cuando conozcas el endpoint para obtener user info
  Future<User?> getUserInfo() async {
    try {
      // TODO: Implementar cuando sepas el endpoint para obtener información del usuario
      // Por ahora, creamos un usuario básico con la información disponible
      final token = await _httpService.getAccessToken();
      if (token != null) {
        // Podrías decodificar el JWT para obtener información básica
        return User(
          id: 1, // Este valor debería venir del JWT o de otro endpoint
          name: 'Usuario', // Este valor debería venir del JWT o de otro endpoint
          email: 'usuario@uninorte.edu.co', // Este valor debería venir del JWT
          imagepathh: null,
        );
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
    return null;
  }

  /// Obtener tokens almacenados
  Future<Map<String, String?>> getStoredTokens() async {
    return {
      'accessToken': await _httpService.getAccessToken(),
      'refreshToken': await _httpService.getRefreshToken(),
    };
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final accessToken = await _httpService.getAccessToken();
    if (accessToken == null) return false;
    
    // Verificar si el token es válido
    return await isTokenValid();
  }

  /// Método de compatibilidad con la implementación anterior
  @deprecated
  Future<List<Map<String, dynamic>>> getUsers() async {
    throw UnsupportedError('getUsers no está disponible en ROBLE API');
  }

  /// Método de compatibilidad con la implementación anterior
  @deprecated
  Future<Map<String, dynamic>?> getUserByCredentials(String email, String password) async {
    final user = await login(email, password);
    return user?.toMap();
  }

  /// Método de compatibilidad con la implementación anterior
  @deprecated
  Future<int> addUser(Map<String, dynamic> user) async {
    final success = await signupDirect(
      user['correo'] ?? user['email'] ?? '',
      user['contrasena'] ?? user['password'] ?? '',
      user['nombre'] ?? user['name'] ?? '',
    );
    return success ? 1 : 0;
  }

  /// Método de compatibilidad con la implementación anterior
  @deprecated
  Future<int> deleteUser(int id) async {
    throw UnsupportedError('deleteUser no está disponible en ROBLE API');
  }

  /// Método de compatibilidad con la implementación anterior
  @deprecated
  Future<int> updateUser(Map<String, dynamic> user) async {
    throw UnsupportedError('updateUser no está disponible en ROBLE API');
  }
}