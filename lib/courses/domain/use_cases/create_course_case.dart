import '../models/course.dart';
import '../repositories/course_repository.dart';

sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}

class CreateCourse {
  CreateCourse(this.repo);
  final CourseRepository repo;

  Future<Result<int>> call(Course course) async {
    try {
      print('📋 Caso de uso CreateCourse iniciado');
      print('📝 Datos recibidos: ${course.toRoble()}');
      
      // Verificar la limitación de 3 cursos máximo por profesor
      print('🔍 Verificando límite de cursos para profesor: ${course.professorId}');
      
      // Intentar obtener cursos existentes del profesor
      List<Course> existingCourses = [];
      try {
        // Verificar si el repositorio tiene el método ROBLE
        if (repo.runtimeType.toString().contains('RobleCourse')) {
          // Es un repositorio ROBLE, usar método específico
          final robleRepo = repo as dynamic;
          existingCourses = await robleRepo.getRobleCoursesByProfesor(course.professorId);
        } else {
          // Fallback para repositorio tradicional (convertir String a int si es necesario)
          final professorIdInt = int.tryParse(course.professorId) ?? 0;
          existingCourses = await repo.getCoursesByProfesor(professorIdInt);
        }
      } catch (e) {
        print('⚠️ Error obteniendo cursos existentes: $e');
        // Continuar con la creación si no se puede verificar (por compatibilidad)
      }
      
      // Verificar límite de 3 cursos
      if (existingCourses.length >= 3) {
        print('❌ Límite alcanzado: ${existingCourses.length} cursos existentes');
        return const Err('Has alcanzado el límite máximo de 3 cursos. No puedes crear más cursos.');
      }
      
      print('✅ Límite verificado: ${existingCourses.length}/3 cursos');
      
      // Crear el curso
      await repo.create(course);
      
      print('✅ Curso creado exitosamente en repositorio');
      return const Ok(0);
    } catch (e) {
      print('❌ Error en caso de uso CreateCourse: $e');
      return Err('Error al crear curso: $e');
    }
  }
}
