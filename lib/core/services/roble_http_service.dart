import 'package:dio/dio.dart';
import 'package:flutter_application/core/config/roble_config.dart';
import 'package:flutter_application/auth/domain/models/auth_models.dart';
import 'package:get_storage/get_storage.dart';

class RobleHttpService {
  late final Dio _dio;
  final GetStorage _storage = GetStorage();

  RobleHttpService() {
    _dio = Dio(BaseOptions(
      baseUrl: RobleConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: RobleConfig.defaultHeaders,
    ));

    // Agregar logging interceptor para debug
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));

    // Interceptor para agregar automáticamente el token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🔍 Interceptor - Endpoint: ${options.path}');
        print('🔍 Interceptor - Es auth endpoint: ${_isAuthEndpoint(options.path)}');
        
        final token = await getAccessToken();
        if (token != null && !_isAuthEndpoint(options.path)) {
          print('🔐 Agregando token de autorización');
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('ℹ️ No se agrega token (endpoint de auth o token no disponible)');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        print('❌ Error en interceptor: ${error.response?.statusCode}');
        // Si recibimos 401, intentamos renovar el token
        if (error.response?.statusCode == 401 && !_isAuthEndpoint(error.requestOptions.path)) {
          print('🔄 Intentando renovar token...');
          final refreshed = await _refreshToken();
          if (refreshed) {
            print('✅ Token renovado, reintentando petición...');
            // Reintentamos la petición original
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));
  }

  bool _isAuthEndpoint(String path) {
    // Solo estos endpoints NO requieren token de autorización
    return path.contains('/login') || 
           path.contains('/signup') || 
           path.contains('/signup-direct') ||
           path.contains('/refresh-token') ||
           path.contains('/forgot-password') ||
           path.contains('/reset-password') ||
           path.contains('/verify-email');
  }

  Future<String?> getAccessToken() async {
    return _storage.read<String>('access_token');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read<String>('refresh_token');
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write('access_token', tokens.accessToken);
    await _storage.write('refresh_token', tokens.refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.remove('access_token');
    await _storage.remove('refresh_token');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        RobleConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokens = AuthTokens.fromJson(response.data);
        await saveTokens(tokens);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  // Métodos de autenticación
  Future<AuthTokens?> login(LoginRequest request) async {
    try {
      print('🚀 Intentando login con URL: ${RobleConfig.baseUrl}${RobleConfig.loginEndpoint}');
      print('📝 Datos enviados: ${request.toJson()}');
      
      final response = await _dio.post(
        RobleConfig.loginEndpoint,
        data: request.toJson(),
      );

      print('✅ Respuesta recibida - Status: ${response.statusCode}');
      print('📦 Datos respuesta: ${response.data}');

      if (response.statusCode == 200) {
        final tokens = AuthTokens.fromJson(response.data);
        await saveTokens(tokens);
        return tokens;
      }
    } on DioException catch (e) {
      print('❌ Error en login: ${e.toString()}');
      throw _handleError(e);
    } catch (e) {
      print('❌ Error inesperado en login: ${e.toString()}');
      throw 'Error inesperado: $e';
    }
    return null;
  }

  Future<bool> signup(SignupRequest request) async {
    try {
      final response = await _dio.post(
        RobleConfig.signupEndpoint,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> signupDirect(SignupRequest request) async {
    try {
      final response = await _dio.post(
        RobleConfig.signupDirectEndpoint,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await _dio.post(
        RobleConfig.verifyEmailEndpoint,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dio.post(
        RobleConfig.forgotPasswordEndpoint,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        RobleConfig.resetPasswordEndpoint,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _dio.post(RobleConfig.logoutEndpoint);
      if (response.statusCode == 200) {
        await clearTokens();
        return true;
      }
    } on DioException catch (e) {
      print('Error during logout: $e');
    }
    await clearTokens(); // Limpiar tokens localmente aunque falle el logout
    return true;
  }

  Future<bool> verifyToken() async {
    try {
      final response = await _dio.get(RobleConfig.verifyTokenEndpoint);
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Token verification failed: $e');
      return false;
    }
  }

  String _handleError(DioException e) {
    print('DioException details:');
    print('- Type: ${e.type}');
    print('- Message: ${e.message}');
    print('- Response: ${e.response?.data}');
    print('- Status Code: ${e.response?.statusCode}');
    print('- Request URL: ${e.requestOptions.uri}');
    print('- Request Data: ${e.requestOptions.data}');
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.connectionError:
        return 'Error de conexión a internet';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        // Intentar obtener mensaje específico del servidor
        String serverMessage = '';
        if (responseData is Map<String, dynamic>) {
          serverMessage = responseData['message'] ?? responseData['error'] ?? '';
        }
        
        switch (statusCode) {
          case 400:
            return serverMessage.isNotEmpty ? 'Error: $serverMessage' : 'Datos inválidos';
          case 401:
            return serverMessage.isNotEmpty ? 'Error: $serverMessage' : 'Credenciales incorrectas';
          case 403:
            return serverMessage.isNotEmpty ? 'Error: $serverMessage' : 'Acceso denegado';
          case 404:
            return 'Servicio no encontrado - Verifica tu dbName: ${RobleConfig.dbName}';
          case 500:
            return serverMessage.isNotEmpty ? 'Error del servidor: $serverMessage' : 'Error del servidor';
          default:
            return 'Error HTTP $statusCode: ${serverMessage.isNotEmpty ? serverMessage : 'Error desconocido'}';
        }
      case DioExceptionType.cancel:
        return 'Petición cancelada';
      default:
        return 'Error de red: ${e.message ?? 'Desconocido'}';
    }
  }
}