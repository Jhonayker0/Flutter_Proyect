import '../../domain/models/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../services/roble_course_service.dart';

class RobleCourseRepositoryImpl implements CourseRepository {
  final RobleCourseService service;
  RobleCourseRepositoryImpl(this.service);

  @override
  Future<void> create(Course course) async {
    await service.createCourse(course);
  }

  @override
  Future<List<Course>> getAll() async {
    return await service.getAllCourses();
  }

  @override
  Future<Course?> getById(int id) async {
    // Convertir int ID a String para ROBLE
    return await service.getCourseById(id.toString());
  }

  // Nuevo método para obtener por String ID (ROBLE)
  Future<Course?> getRobleById(String id, {String? currentUserId}) async {
    return await service.getCourseById(id, currentUserId: currentUserId);
  }

  @override
  Future<void> update(Course course) async {
    if (course.id != null) {
      await service.updateCourse(course.id!, course);
    }
  }

  @override
  Future<void> delete(int id) async {
    await service.deleteCourse(id.toString());
  }

  // Nuevo método para eliminar por String ID (ROBLE)
  Future<void> deleteRoble(String id) async {
    await service.deleteCourse(id);
  }

  @override
  Future<List<Course>> getCoursesByStudent(int studentId) async {
    return await service.getCoursesByStudent(studentId.toString());
  }

  // Nuevo método para student con String ID (ROBLE)
  Future<List<Course>> getRobleCoursesByStudent(String studentId) async {
    return await service.getCoursesByStudent(studentId);
  }

  @override
  Future<List<Course>> getCoursesByProfesor(int profesorId) async {
    return await service.getCoursesByProfessor(profesorId.toString());
  }

  // Nuevo método para profesor con String ID (ROBLE)
  Future<List<Course>> getRobleCoursesByProfesor(String profesorId) async {
    return await service.getCoursesByProfessor(profesorId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersByCourse(int courseId) async {
    // TODO: Implementar cuando tengamos enrollments
    // Por ahora retornamos lista vacía
    return [];
  }

  @override
  Future<int> joinCourseByCode({required int studentId, required String courseCode}) async {
    // TODO: Implementar con enrollments
    // Por ahora retornamos 0 (éxito)
    return 0;
  }
}