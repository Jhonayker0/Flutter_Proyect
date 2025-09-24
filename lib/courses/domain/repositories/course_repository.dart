import 'package:flutter_application/courses/domain/models/course.dart'
    show Course;

abstract class CourseRepository {
  Future<void> create(Course course);

  Future<List<Course>> getAll();

  Future<Course?> getById(int id);

  Future<void> update(Course course);

  Future<void> delete(int id);

  Future<List<Course>> getCoursesByProfesor(int userId);

  Future<List<Course>> getCoursesByStudent(int userId);
  Future<List<Map<String, dynamic>>> getUsersByCourse(int courseId);
  Future<int> joinCourseByCode({
    required int studentId,
    required String courseCode,
  });
}
