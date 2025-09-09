import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/home_controller_new.dart';
import 'package:flutter_application/routes.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/use_cases/create_course_case.dart';
import '../controllers/auth_controller.dart';

class CreateCourseController extends GetxController {
  final CreateCourse createCourseUseCase;
  CreateCourseController({required this.createCourseUseCase});


  final AuthController authController = Get.find<AuthController>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final isLoading = false.obs;
  final error = RxnString();

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  Future<void> submit(GlobalKey<FormState> formKey, BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final userId = authController.currentUser.value?.id;
    if (userId == null) {
      error.value = 'Usuario no logeado';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final course = Course(
        title: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        profesorId: userId,
        role: 'Professor',   // rol del creador  
        createdAt: DateTime.now(),
      );
      final res =await createCourseUseCase(course);
      switch (res){
        case Ok():            
          Get.snackbar(
            'Éxito',
            'Curso creado correctamente',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          
          nameCtrl.clear();
          descCtrl.clear();

          final  homeController = Get.find<HomeController>();
          homeController.loadCourses(); 

          Get.offNamed(Routes.home);
          break;
        case Err(message: final m):
          Get.snackbar('Error', 'No se pudo crear el curso $m',
          backgroundColor: Colors.red, colorText: Colors.white);
      
      }
      

    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el curso $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
