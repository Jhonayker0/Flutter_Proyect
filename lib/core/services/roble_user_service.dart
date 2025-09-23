import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_application/core/config/roble_config.dart';
import 'roble_database_service.dart';

class RobleUserService {
  final RobleDatabaseService _databaseService;

  RobleUserService(this._databaseService);

  /// Obtener usuarios por curso con información de rol
  Future<List<Map<String, dynamic>>> getUsersByCourse(String courseId) async {
    try {
      print('👥 Buscando usuarios para curso: $courseId');

      // Obtener todos los enrollments del curso
      final enrollments = await _databaseService.read('enrollments');

      if (enrollments.isEmpty) {
        print('📋 No hay enrollments en el sistema');
        return [];
      }

      // Filtrar por curso específico
      final courseEnrollments = enrollments
          .where((enrollment) => enrollment['course_id'] == courseId)
          .toList();

      print('📋 Enrollments del curso: ${courseEnrollments.length}');

      if (courseEnrollments.isEmpty) {
        return [];
      }

      print('👤 Intentando obtener información real de usuarios');

      // Para cada enrollment, obtener información del usuario
      final users = <Map<String, dynamic>>[];

      for (final enrollment in courseEnrollments) {
        final userId = enrollment['student_id'] as String?;
        final role = enrollment['role'] as String? ?? 'student';

        if (userId == null) continue;

        // Intentar obtener información real del usuario
        final userInfo = await _getUserRealInfo(userId, role);

        if (userInfo != null) {
          users.add(userInfo);
        } else {
          // Fallback: crear usuario básico con UUID
          users.add(await _createFallbackUser(userId, role));
        }
      }

      print('✅ Usuarios encontrados: ${users.length}');
      return users;
    } catch (e) {
      print('❌ Error obteniendo usuarios por curso: $e');
      return [];
    }
  }

  /// Crear usuario básico con UUID cuando no se encuentra información
  Future<Map<String, dynamic>> _createFallbackUser(
    String uuid,
    String role,
  ) async {
    return {
      '_id': uuid,
      'name': 'Usuario',
      'email': '$uuid@uninorte.edu.co',
      'avatarUrl': null,
      'role': role,
    };
  }

  /// Consultar información de usuario por ID usando la API de autenticación
  Future<Map<String, String>?> _getUserInfoFromAuth(String userId) async {
    try {
      print('🔍 Consultando auth API para usuario: $userId');

      // Usar el servicio HTTP de la aplicación para hacer la consulta
      final dio = Dio();
      dio.options.baseUrl = RobleConfig.baseUrl;
      dio.options.headers = RobleConfig.defaultHeaders;

      // Obtener token actual para autorización
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      if (currentUser?.uuid != null) {
        // Agregar header de autorización si tenemos token
        dio.options.headers['Authorization'] =
            'Bearer ${await _getAccessToken()}';
      }

      // Consultar endpoint de información de usuario
      final response = await dio.get(
        '/auth/${RobleConfig.dbName}/user-info/$userId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;
        print(
          '✅ Información obtenida del auth: ${userData['email'] ?? userData['name']}',
        );

        return {
          'name': userData['name'] ?? userData['email'] ?? 'Usuario',
          'email': userData['email'] ?? '$userId@uninorte.edu.co',
        };
      }
    } catch (e) {
      print('❌ Error consultando auth API para $userId: $e');
    }

    return null;
  }

  /// Obtener token de acceso actual
  Future<String?> _getAccessToken() async {
    try {
      // Por ahora retornamos null - el AuthController maneja la autorización internamente
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener información del usuario autenticado actual
  Future<Map<String, String>?> _getCurrentUserInfo() async {
    try {
      // Obtener el usuario actual desde el AuthController
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser != null) {
        return {
          'userId': currentUser.uuid ?? '',
          'name': currentUser.email, // Siempre mostrar el email
        };
      }
    } catch (e) {
      print('❌ Error obteniendo usuario autenticado: $e');
    }

    return null;
  }

  /// Intenta obtener información real del usuario (ahora consulta auth API)
  Future<Map<String, dynamic>?> _getUserRealInfo(
    String uuid,
    String role,
  ) async {
    try {
      print('🔍 Intentando obtener info real para usuario: $uuid');

      // Obtener información del usuario actual autenticado
      final currentUserInfo = await _getCurrentUserInfo();

      // Si es el usuario actual, usar su información
      if (currentUserInfo != null && currentUserInfo['userId'] == uuid) {
        print('✅ Es el usuario actual autenticado: ${currentUserInfo['name']}');
        return {
          '_id': uuid,
          'name': currentUserInfo['name']!,
          'email': 'id: $uuid',
          'avatarUrl': null,
          'role': role,
        };
      }

      // Para otros usuarios, intentar consultar la API de autenticación
      final authUserInfo = await _getUserInfoFromAuth(uuid);
      if (authUserInfo != null) {
        print('✅ Información obtenida de auth API: ${authUserInfo['name']}');
        return {
          '_id': uuid,
          'name': authUserInfo['name']!,
          'email': authUserInfo['email']!,
          'avatarUrl': null,
          'role': role,
        };
      }

      // Fallback: mostrar rol en lugar de email
      final roleDisplayName = role == 'professor' ? 'Profesor' : 'Estudiante';
      print('📧 Usando fallback - mostrando rol: $roleDisplayName');

      return {
        '_id': uuid,
        'name': roleDisplayName, // Mostrar rol como nombre
        'email': 'id: $uuid',
        'avatarUrl': null,
        'role': role,
      };
    } catch (e) {
      print('❌ Error obteniendo información real del usuario: $e');
      return null;
    }
  }
}
