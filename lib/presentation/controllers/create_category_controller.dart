// presentation/controllers/create_category_controller.dart
import 'package:flutter_application/domain/models/category.dart';
import 'package:flutter_application/domain/use_cases/create_category_case.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateCategoryController extends GetxController {
  final CreateCategory createCategoryUseCase;
  CreateCategoryController({required this.createCategoryUseCase});

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();

  final type = RxnString(); // "Auto-asignado" | "Aleatorio"
  final isLoading = false.obs;
  final error = RxnString();

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? validateType(String? v) => v == null ? 'Selecciona un tipo' : null;

  String? validateCapacity(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa la capacidad';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Debe ser un número mayor a 0';
    return null;
  }

  void setType(String? v) => type.value = v;

  Future<void> submit(GlobalKey<FormState> formKey, BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    error.value = null;
    try {
      final n = int.parse(capacityCtrl.text.trim());
      final category = Category(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        type: type.value!, // validado
        capacity: n,
      );
      await createCategoryUseCase(category);
      Get.snackbar('exito', 'Categoría creada');
      Get.back();
    } catch (e) {
      error.value = 'No se pudo crear la categoría';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    capacityCtrl.dispose();
    super.onClose();
  }
}
