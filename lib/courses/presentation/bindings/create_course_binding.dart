import 'package:get/get.dart';
import '../../data/services/course_service.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/use_cases/create_course_case.dart';
import '../controllers/create_course_controller.dart';

class CreateCourseBinding extends Bindings {
  @override
  void dependencies() {
    final service = CourseService();
    final repo = CourseRepositoryImpl(service);
    final useCase = CreateCourse(repo);
    Get.put(CreateCourseController(createCourseUseCase: useCase));
  }
}







