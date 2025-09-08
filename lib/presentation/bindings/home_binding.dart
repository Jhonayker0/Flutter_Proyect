import 'package:get/get.dart';
import '../controllers/home_controller_new.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/services/course_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      final service = CourseService();
      final repository = CourseRepositoryImpl(service);
      Get.put<HomeController>(HomeController(courseRepository: repository));
    }
  }
}
