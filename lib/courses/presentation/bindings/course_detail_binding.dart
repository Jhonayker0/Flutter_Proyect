import 'package:flutter_application/courses/data/repositories/course_repository_impl.dart';
import 'package:flutter_application/courses/data/services/course_service.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailBinding extends Bindings {
  @override
  void dependencies() {
    final service = CourseService();
    final repo = CourseRepositoryImpl(service);
    Get.put(CourseDetailController(repo: repo));
  }
}







