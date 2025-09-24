import 'package:flutter/material.dart';
import 'package:flutter_application/courses/domain/repositories/course_repository.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_application/core/presentation/controllers/home_controller_new.dart';
import 'package:get/get.dart';

class JoinCourseController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final codeCtrl = TextEditingController();
  final isLoading = false.obs;
  final AuthController authController = Get.find<AuthController>();
  final CourseRepository repo;
  JoinCourseController({required this.repo});
  Future<void> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final userId = authController.currentUser.value?.id;
    isLoading.value = true;
    try {
      final code = codeCtrl.text.trim();

      final enrollmentId = await repo.joinCourseByCode(
        studentId: userId!,
        courseCode: code,
      );
      final homeController = Get.find<HomeController>();
      homeController.loadCourses();
      Get.back(result: enrollmentId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    super.onClose();
  }
}
