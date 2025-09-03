import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CourseDetailController());
  }
}
