import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/delete_category_use_case.dart';
import '../../routes.dart';

class CategoriesController extends GetxController {
  final GetCategories getCategoriesUseCase;
  final DeleteCategory deleteCategoryUseCase;
  final courseid = 0;
  CategoriesController({
    required this.getCategoriesUseCase,
    required this.deleteCategoryUseCase,
  });

  final RxList<Category> categories = <Category>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    error.value = null;

    try {
      final result = await getCategoriesUseCase(courseid);
      categories.assignAll(result);
    } catch (e) {
      error.value = 'Error al cargar categorías';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await deleteCategoryUseCase(id);
      categories.removeWhere((cat) => cat.id == id);
      Get.snackbar('Éxito', 'Categoría eliminada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar la categoría');
    }
  }

  void goToCreateCategory() {
    Get.toNamed(Routes.createCategory)?.then((_) => loadCategories());
  }

  void goToEditCategory(Category category) {
    Get.toNamed('${Routes.editCategory}/${category.id}')?.then((_) => loadCategories());
  }

  Future<void> confirmDelete(Category category) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true && category.id != null) {
      await deleteCategory(category.id!);
    }
  }
}
