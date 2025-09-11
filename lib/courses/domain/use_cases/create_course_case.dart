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
    final cursos = await repo.getCoursesByProfesor(course.profesorId);
    if (cursos.length >= 3) {
      return const Err('ya tienes 3');
    }
    await repo.create(course);
    return Ok(0);
  }
}







