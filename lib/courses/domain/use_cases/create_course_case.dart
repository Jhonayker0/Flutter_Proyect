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
      
      // Crear el curso directamente sin restricción de cantidad por ahora
      await repo.create(course);
      
      print('✅ Curso creado exitosamente en repositorio');
      return const Ok(0);
    } catch (e) {
      print('❌ Error en caso de uso CreateCourse: $e');
      return Err('Error al crear curso: $e');
    }
  }
}
