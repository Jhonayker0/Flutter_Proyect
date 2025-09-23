import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_category_service.dart';
import 'package:flutter_application/courses/data/repositories/roble_course_repository_impl.dart';
import 'package:flutter_application/courses/data/services/roble_course_service.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Configurar servicios ROBLE
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final courseService = RobleCourseService(databaseService);
    final categoryService = RobleCategoryService(databaseService);
    final repo = RobleCourseRepositoryImpl(courseService);

    // Registrar servicios en GetX
    Get.put(categoryService);
    Get.put(CourseDetailController(repo: repo));
  }
}
