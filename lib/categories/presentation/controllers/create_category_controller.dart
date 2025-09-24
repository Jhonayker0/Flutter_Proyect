// presentation/controllers/create_category_controller.dart
import 'package:flutter_application/categories/domain/models/category.dart';
import 'package:flutter_application/categories/domain/use_cases/create_category_case.dart';
import 'package:flutter_application/courses/presentation/controllers/course_detail_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateCategoryController extends GetxController {
  final CreateCategory createCategoryUseCase;
  CreateCategoryController({required this.createCategoryUseCase});
  late final String courseId;
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final type = RxnString(); // "aleatorio" | "eleccion"
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null && args['courseId'] != null) {
      courseId = (args['courseId'] as String);
    } else {
      // Valor por defecto o manejo de error
      Get.snackbar(
        'Error',
        'ID del curso no encontrado',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }
  }

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? validateType(String? v) => v == null ? 'Selecciona un tipo' : null;

  void setType(String? v) => type.value = v;

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    error.value = null;
    try {
      final category = Category(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        type: type.value!, // validado
        courseId: courseId, // Ya es String
      );
      await createCategoryUseCase.call(category);

      // Refrescar las categorías en el curso
      if (Get.isRegistered<CourseDetailController>()) {
        Get.find<CourseDetailController>().loadRobleCategories();
      }
      Get.back(result: true);
      Get.snackbar('Exito', 'Categoría creada');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la categoría $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
