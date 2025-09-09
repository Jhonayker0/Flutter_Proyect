import 'package:flutter_application/domain/models/activity.dart';
import 'package:flutter_application/domain/use_cases/create_activity_case.dart';
import 'package:flutter_application/domain/repositories/activity_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateActivityController extends GetxController {
  final CreateActivity createActivityUC;
  final ActivityRepository activityRepository;
  CreateActivityController({
    required this.createActivityUC,
    required this.activityRepository,
  });

  late final int courseId;

  // Campos de UI
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final deadline = Rxn<DateTime>();
  final selectedCategoryId = RxnInt();
  final isLoading = false.obs;
  final error = RxnString();

  // Lista de categorías del curso
  final categories = <Map<String, dynamic>>[].obs;

  // Opcional: archivo adjunto (ruta/local/ID)
  final attachmentPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    courseId = (args?['courseId'] as num).toInt();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await activityRepository.getCategoriesByCourse(courseId);
      categories.assignAll(cats);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las categorías');
    }
  }

  // Validaciones simples para apoyar a la vista
  String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Por favor ingresa un nombre' : null;

  String? validateCategory(int? v) =>
      (v == null) ? 'Por favor selecciona una categoría' : null;

  void setDeadline(DateTime? d) => deadline.value = d;
  void setCategory(int? categoryId) => selectedCategoryId.value = categoryId;
  void setAttachment(String? path) => attachmentPath.value = path;

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedCategoryId.value == null) {
      Get.snackbar('Error', 'Por favor selecciona una categoría');
      return;
    }

    isLoading.value = true;
    error.value = null;
    try {
      final activity = Activity(
        title: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty
            ? 'Sin descripción'
            : descCtrl.text.trim(),
        dueDate: deadline.value ?? DateTime.now().add(const Duration(days: 7)),
        type: 'Tarea', // Tipo por defecto, se puede hacer configurable
        categoryId: selectedCategoryId.value!,
      );

      await createActivityUC(activity);
      Get.back(result: true);
      Get.snackbar('Éxito', 'Actividad creada exitosamente');
    } catch (e) {
      error.value = 'No se pudo crear la actividad: $e';
      Get.snackbar(
        'Error',
        'No se pudo crear la actividad',
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
