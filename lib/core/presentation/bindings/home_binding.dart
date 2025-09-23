import 'package:get/get.dart';
import '../controllers/home_controller_new.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/courses/data/repositories/roble_course_repository_impl.dart';
import 'package:flutter_application/courses/data/services/roble_course_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      // Configurar servicios ROBLE
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);
      final courseService = RobleCourseService(databaseService);
      final repository = RobleCourseRepositoryImpl(courseService);
      
      Get.put<HomeController>(HomeController(courseRepository: repository));
    }
  }
}







