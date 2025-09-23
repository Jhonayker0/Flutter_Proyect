import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/activities/domain/use_cases/create_activity_case.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateActivityController extends GetxController {
  final CreateActivity createActivityUC;
  CreateActivityController({required this.createActivityUC});

  // Campos de UI
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final deadline = Rxn<DateTime>();
  final category = RxnString();
  final isLoading = false.obs;
  final error = RxnString();

  // Opcional: archivo adjunto (ruta/local/ID)
  final attachmentPath = RxnString();

  // Validaciones simples para apoyar a la vista
  String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Por favor ingresa un nombre' : null;

  String? validateCategory(String? v) =>
      (v == null) ? 'Por favor selecciona una categoría' : null;

  void setDeadline(DateTime? d) => deadline.value = d;
  void setCategory(String? c) => category.value = c;
  void setAttachment(String? path) => attachmentPath.value = path;

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    error.value = null;
    try {
      final activity = Activity(
        title: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty
            ? 'Sin descripción'
            : descCtrl.text.trim(),
        dueDate: deadline.value ?? DateTime.now().add(Duration(days: 7)),
        type: category.value ?? 'Tarea',
        courseId: 1, // TODO: Obtener el courseId actual
      );

      await createActivityUC(activity);
      Get.snackbar('Éxito', 'Actividad creada');
      Get.back(); // o navegación custom
    } catch (e) {
      error.value = 'No se pudo crear la actividad';
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
