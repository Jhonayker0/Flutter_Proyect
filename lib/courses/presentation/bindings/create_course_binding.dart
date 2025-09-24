import 'package:get/get.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import '../../data/services/roble_course_service.dart';
import '../../data/repositories/roble_course_repository_impl.dart';
import '../../domain/use_cases/create_course_case.dart';
import '../controllers/create_course_controller.dart';

class CreateCourseBinding extends Bindings {
  @override
  void dependencies() {
    final dbService = RobleDatabaseService(RobleHttpService());
    final service = RobleCourseService(dbService);
    final repo = RobleCourseRepositoryImpl(service);
    final useCase = CreateCourse(repo);
    Get.put(CreateCourseController(createCourseUseCase: useCase));
  }
}
