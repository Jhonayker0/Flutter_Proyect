import 'package:flutter_application/data/repositories/course_repository_impl.dart';
import 'package:flutter_application/data/repositories/activity_repository_impl.dart';
import 'package:flutter_application/data/services/course_service.dart';
import 'package:flutter_application/data/services/activity_service.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailBinding extends Bindings {
  @override
  void dependencies() {
    final courseService = CourseService();
    final courseRepo = CourseRepositoryImpl(courseService);

    final activityService = ActivityService();
    final activityRepo = ActivityRepositoryImpl(activityService);

    Get.put(
      CourseDetailController(repo: courseRepo, activityRepo: activityRepo),
    );
  }
}
