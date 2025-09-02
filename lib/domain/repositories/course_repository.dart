import 'package:flutter_application/domain/models/course.dart' show Course;

abstract class CourseRepository {
  Future<void> create(Course course);
}
