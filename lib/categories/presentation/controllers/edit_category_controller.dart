import 'package:flutter/material.dart';
import 'package:flutter_application/categories/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/use_cases/update_category_use_case.dart';
import '../../domain/repositories/category_repository.dart';

class EditCategoryController extends GetxController {
  final UpdateCategory updateCategoryUseCase;
  final CategoryRepository categoryRepository;

  EditCategoryController({
    required this.updateCategoryUseCase,
    required this.categoryRepository,
  });

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final type = RxnString();
  final isLoading = false.obs;
  final error = RxnString();

  Category? _originalCategory;

  @override
  void onInit() {
    super.onInit();
    final categoryId = int.tryParse(Get.parameters['id'] ?? '');
    if (categoryId != null) {
      loadCategory(categoryId);
    }
  }

  Future<void> loadCategory(int id) async {
    isLoading.value = true;
    try {
      _originalCategory = await categoryRepository.getById(id.toString());
      if (_originalCategory != null) {
        nameCtrl.text = _originalCategory!.name;
        descCtrl.text = _originalCategory!.description ?? '';
        type.value = _originalCategory!.type;
      }
    } catch (e) {
      error.value = 'Error al cargar la categoría';
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (_originalCategory == null) return;

    isLoading.value = true;
    error.value = null;
    try {
      final updatedCategory = _originalCategory!.copyWith(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        type: type.value!,
      );

      await updateCategoryUseCase(updatedCategory);

      if (Get.isRegistered<CategoryGroupsController>()) {
        Get.find<CategoryGroupsController>().refreshAll();
      }
      Get.back();
      Get.snackbar('Éxito', 'Categoría actualizada');
    } catch (e) {
      error.value = 'No se pudo actualizar la categoría';
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
