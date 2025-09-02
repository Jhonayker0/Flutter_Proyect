import 'package:flutter_application/domain/models/course.dart';
import 'package:flutter_application/domain/repositories/course_repository.dart';

import '../services/course_service.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseService service;
  CourseRepositoryImpl(this.service);

  @override
  Future<void> create(Course course) async {
    final dto = {
      'name': course.name,
      'description': course.description,
      'deadline': course.deadline?.toIso8601String(),
      'imagePath': course.imagePath,
    };
    await service.postCourse(dto);
  }
}
