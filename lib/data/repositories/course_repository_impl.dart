import '../../domain/models/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../services/course_service.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseService service;
  CourseRepositoryImpl(this.service);

  @override
  Future<void> create(Course course) async {
    final dto = course.toMap();
    await service.postCourse(dto);
  }

  @override
  Future<List<Course>> getAll() async {
    final data = await service.getCourses();
    // Convertir cada registro a Course, usando id logeado para determinar rol
    return data.map((map) => Course.fromMap(map)).toList();
  }

  @override
  Future<Course?> getById(int id) async {
    final data = await service.getCourses();
    final map = data.firstWhere((e) => e['id'] == id, orElse: () => {});
    if (map.isEmpty) return null;
    return Course.fromMap(map);
  }

  @override
  Future<void> update(Course course) async {
    // Implementar si se necesita actualizar cursos
  }

  @override
  Future<void> delete(int id) async {
    await service.deleteCourse(id);
  }

  @override
  Future<List<Course>> getCoursesByStudent(int studentId) async {
    final data = await service.getCoursesByEstudiante(studentId);
    return data.map((map) => Course.fromMap(map, currentUserId: studentId)).toList();
  }

  @override
  Future<List<Course>> getCoursesByProfesor(int profesorId) async {
    final data = await service.getCoursesByProfesor(profesorId);
    return data.map((map) => Course.fromMap(map, currentUserId: profesorId)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersByCourse(int courseId) async {
    return await service.getUsersByCourse(courseId);
  }
}
