import 'package:flutter_application/courses/domain/models/course.dart';
import 'package:flutter_application/courses/domain/use_cases/create_course_case.dart';
import 'package:flutter_application/courses/data/repositories/roble_course_repository_impl.dart';
import 'package:flutter_application/courses/data/services/roble_course_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';

/// Prueba para verificar la limitación de 3 cursos por usuario
Future<void> testCourseLimit() async {
  try {
    print('🧪 Iniciando prueba de límite de cursos...');
    
    // Configurar servicios
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final courseService = RobleCourseService(databaseService);
    final repository = RobleCourseRepositoryImpl(courseService);
    final createCourseUseCase = CreateCourse(repository);
    
    final testProfessorId = 'test-professor-uuid';
    
    // Intentar crear 4 cursos para probar el límite
    for (int i = 1; i <= 4; i++) {
      print('\n🔄 Intentando crear curso $i...');
      
      final course = Course(
        title: 'Curso de Prueba $i',
        description: 'Descripción del curso de prueba $i',
        professorId: testProfessorId,
        role: 'Professor',
        createdAt: DateTime.now(),
      );
      
      final result = await createCourseUseCase(course);
      
      switch (result) {
        case Ok():
          print('✅ Curso $i creado exitosamente');
        case Err(message: final message):
          print('❌ Error creando curso $i: $message');
          if (message.contains('límite máximo')) {
            print('🎯 ¡Límite de 3 cursos funcionando correctamente!');
            return;
          }
      }
    }
    
    print('⚠️ No se activó el límite de cursos como esperado');
    
  } catch (e) {
    print('💥 Error en prueba: $e');
  }
}

void main() async {
  await testCourseLimit();
}