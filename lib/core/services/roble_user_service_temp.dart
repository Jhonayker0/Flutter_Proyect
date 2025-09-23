import 'package:flutter_application/core/services/roble_database_service.dart';

class RobleUserService {
  final RobleDatabaseService _databaseService;

  RobleUserService(this._databaseService);

  /// Obtiene los usuarios de un curso específico con sus roles
  Future<List<Map<String, dynamic>>> getUsersByCourse(String courseId) async {
    try {
      print('👥 Buscando usuarios para curso: $courseId');

      // 1. Obtener enrollments del curso
      final enrollments = await _databaseService.read('enrollments');
      final courseEnrollments = enrollments
          .where((enrollment) => enrollment['course_id'] == courseId)
          .toList();

      print('📋 Enrollments del curso: ${courseEnrollments.length}');

      if (courseEnrollments.isEmpty) {
        print('👥 No hay usuarios en el curso $courseId');
        return [];
      }

      // 2. Como la tabla 'users' no existe, crear usuarios dummy basados en enrollments
      print(
        '👤 Creando usuarios basados en enrollments (tabla users no disponible)',
      );

      // 3. Crear lista de usuarios con roles basada solo en enrollments
      final courseUsers = <Map<String, dynamic>>[];

      for (var enrollment in courseEnrollments) {
        final studentId = enrollment['student_id'];
        final role = enrollment['role'] ?? 'student';

        // Crear usuario básico basado en UUID del enrollment
        courseUsers.add({
          'id': studentId,
          'name': 'Usuario ${studentId.substring(0, 8)}', // Nombre genérico
          'email': '${studentId.substring(0, 8)}@example.com', // Email genérico
          'imagepathh': null,
          'role': role, // Rol del enrollment
          'uuid': studentId, // UUID original
        });
      }

      print('✅ Usuarios encontrados: ${courseUsers.length}');
      return courseUsers;
    } catch (e) {
      print('❌ Error obteniendo usuarios del curso: $e');
      return [];
    }
  }

  /// Obtiene un usuario específico por UUID (fallback con datos dummy)
  Future<Map<String, dynamic>?> getUserByUuid(String uuid) async {
    try {
      // Como no tenemos tabla users, crear usuario dummy
      return {
        '_id': uuid,
        'name': 'Usuario ${uuid.substring(0, 8)}',
        'email': '${uuid.substring(0, 8)}@example.com',
        'avatarUrl': null,
      };
    } catch (e) {
      print('❌ Error obteniendo usuario por UUID: $e');
      return null;
    }
  }
}
