import 'package:flutter_application/courses/data/repositories/course_repository_impl.dart';
import 'package:flutter_application/courses/data/services/course_service.dart';
import 'package:flutter_application/courses/presentation/controllers/join_course_controller.dart';
import 'package:get/get.dart';

class JoinCourseBinding extends Bindings {
  @override
  void dependencies() {
    // Si no hay repositorio aún, basta con el controller
    final service = CourseService();
    final repo = CourseRepositoryImpl(service);
    Get.put<JoinCourseController>(JoinCourseController(repo: repo));
  }
}
