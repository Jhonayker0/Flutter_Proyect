import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/courses/data/services/roble_course_service.dart';

/// Función de prueba para verificar la conexión a ROBLE
Future<void> testRobleConnection() async {
  try {
    print('🧪 Iniciando prueba de conexión ROBLE...');

    // Crear servicios
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final courseService = RobleCourseService(databaseService);

    // Probar obtener cursos
    print('📚 Obteniendo cursos desde ROBLE...');
    final courses = await courseService.getAllCourses();

    print('✅ Conexión exitosa! Cursos encontrados: ${courses.length}');
    for (final course in courses) {
      print('  - ${course.title} (ID: ${course.id})');
    }
  } catch (e) {
    print('❌ Error en prueba ROBLE: $e');
  }
}

/// Función de prueba para verificar cursos por profesor
Future<void> testCoursesByProfessor(String professorId) async {
  try {
    print('🧪 Probando cursos por profesor ID: $professorId');

    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final courseService = RobleCourseService(databaseService);

    final courses = await courseService.getCoursesByProfessor(professorId);

    print('✅ Cursos del profesor ($professorId): ${courses.length}');
    for (final course in courses) {
      print('  - ${course.title} (Rol: ${course.role})');
    }
  } catch (e) {
    print('❌ Error obteniendo cursos del profesor: $e');
  }
}
