import 'package:flutter_application/core/services/roble_database_service.dart';

class RobleEnrollmentService {
  final RobleDatabaseService _databaseService;
  static const String tableName = 'enrollments';

  RobleEnrollmentService(this._databaseService);

  /// Obtener cursos donde el usuario está inscrito como estudiante
  Future<List<String>> getCourseIdsByStudent(String studentId) async {
    try {
      final data = await _databaseService.read(tableName);
      
      // Filtrar enrollments donde student_id coincide
      final userEnrollments = data.where((enrollment) {
        return enrollment['student_id'] == studentId;
      }).toList();
      
      // Extraer los course_ids
      final courseIds = userEnrollments
          .map((enrollment) => enrollment['course_id'] as String?)
          .where((courseId) => courseId != null)
          .cast<String>()
          .toList();
      
      print('📚 Usuario $studentId inscrito en ${courseIds.length} cursos: $courseIds');
      return courseIds;
    } catch (e) {
      print('❌ Error obteniendo inscripciones del estudiante: $e');
      return [];
    }
  }

  /// Obtener estudiantes inscritos en un curso
  Future<List<String>> getStudentIdsByCourse(String courseId) async {
    try {
      final data = await _databaseService.read(tableName);
      
      // Filtrar enrollments donde course_id coincide
      final courseEnrollments = data.where((enrollment) {
        return enrollment['course_id'] == courseId;
      }).toList();
      
      // Extraer los student_ids
      final studentIds = courseEnrollments
          .map((enrollment) => enrollment['student_id'] as String?)
          .where((studentId) => studentId != null)
          .cast<String>()
          .toList();
      
      return studentIds;
    } catch (e) {
      print('❌ Error obteniendo estudiantes del curso: $e');
      return [];
    }
  }

  /// Inscribir un estudiante en un curso
  Future<void> enrollStudent(String studentId, String courseId, {String role = 'student'}) async {
    try {
      await _databaseService.insert(tableName, [{
        'student_id': studentId,
        'course_id': courseId,
        'role': role,
      }]);
      print('✅ Usuario $studentId inscrito en curso $courseId');
    } catch (e) {
      print('❌ Error inscribiendo estudiante: $e');
      rethrow;
    }
  }

  /// Desinscribir un estudiante de un curso
  Future<void> unenrollStudent(String studentId, String courseId) async {
    try {
      final data = await _databaseService.read(tableName);
      
      // Buscar el enrollment específico
      final enrollment = data.firstWhere(
        (enroll) => enroll['student_id'] == studentId && enroll['course_id'] == courseId,
        orElse: () => <String, dynamic>{},
      );
      
      if (enrollment.isNotEmpty && enrollment['_id'] != null) {
        await _databaseService.delete(tableName, enrollment['_id'] as String);
        print('✅ Usuario $studentId desinscrito del curso $courseId');
      } else {
        print('⚠️ No se encontró inscripción para desinscribir');
      }
    } catch (e) {
      print('❌ Error desinscribiendo estudiante: $e');
      rethrow;
    }
  }
}