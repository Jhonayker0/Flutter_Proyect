import 'package:flutter_application/domain/models/course.dart';
import 'package:flutter_application/domain/use_cases/create_course_case.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class CreateCourseController extends GetxController {
  final CreateCourse createCourseUseCase;
  CreateCourseController({required this.createCourseUseCase});

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final deadline = Rxn<DateTime>();
  final imagePath = RxnString();

  final isLoading = false.obs;
  final error = RxnString();

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  void setDeadline(DateTime? d) => deadline.value = d;
  void setImagePath(String? path) => imagePath.value = path;

  Future<void> submit(GlobalKey<FormState> formKey, BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    error.value = null;
    try {
      final course = Course(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        deadline: deadline.value,
        imagePath: imagePath.value,
      );
      await createCourseUseCase(course);
      Get.snackbar('exito', 'Curso creado');
      Get.back();
    } catch (e) {
      error.value = 'No se pudo crear el curso';
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
