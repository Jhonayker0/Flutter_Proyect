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
        // Usar la información del usuario de la respuesta de login
        if (tokens.user != null) {
          return User.fromJson(tokens.user!);
        } else {
          // Fallback: obtener la información del usuario por separado
          return await getUserInfo();
        }
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
  Future<User?> getUserInfo() async {
    try {
      // Verificar el token y obtener información del usuario
      final verifyResponse = await _httpService.dio.get('/auth/movilapp_a4de2ed3d7/verify-token');
      
      if (verifyResponse.statusCode == 200 && verifyResponse.data['valid'] == true) {
        final userData = verifyResponse.data['user'];
        
        return User(
          id: userData['sub'].hashCode.abs(), // Usar hash del UUID como int ID
          name: userData['email'] ?? 'Usuario', // Temporal, hasta tener el name
          email: userData['email'] ?? 'usuario@uninorte.edu.co',
          imagepathh: null,
          uuid: userData['sub'], // Guardar el UUID original
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