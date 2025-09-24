import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/activities/domain/use_cases/create_activity_case.dart';
import 'package:flutter_application/core/services/roble_category_service.dart';
import 'package:flutter_application/courses/presentation/controllers/course_detail_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateActivityController extends GetxController {
  final CreateActivity createActivityUC;
  final RobleCategoryService _categoryService;
  
  CreateActivityController({
    required this.createActivityUC,
    required RobleCategoryService categoryService,
  }) : _categoryService = categoryService;

  // Campos de UI
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final deadline = Rxn<DateTime>();
  final selectedCategoryId = RxnString();
  final isLoading = false.obs;
  final error = RxnString();

  // Datos del curso y categorías
  late String courseId;
  final categories = <Map<String, dynamic>>[].obs;
  final isLoadingCategories = false.obs;

  // Validaciones simples para apoyar a la vista
  String? validateName(String? v) {
    final isValid = v != null && v.trim().isNotEmpty;
    print('📝 Validación nombre: "${v}" -> ${isValid ? "válido" : "inválido"}');
    return isValid ? null : 'Por favor ingresa un nombre';
  }

  String? validateCategory(String? v) {
    final isValid = v != null && v.isNotEmpty;
    print('📂 Validación categoría: "${v}" -> ${isValid ? "válido" : "inválido"}');
    return isValid ? null : 'Por favor selecciona una categoría';
  }

  @override
  void onInit() {
    super.onInit();
    print('🏁 CreateActivityController - onInit iniciado');
    
    // Obtener courseId de los argumentos
    final args = Get.arguments as Map<String, dynamic>?;
    courseId = args?['courseId']?.toString() ?? '';
    print('📝 Argumentos recibidos: $args');
    print('🆔 CourseId extraído: $courseId');
    
    if (courseId.isNotEmpty) {
      print('📚 Cargando categorías para el curso...');
      loadCategories();
    } else {
      print('❌ CourseId vacío, no se pueden cargar categorías');
    }
  }

  void setDeadline(DateTime? d) => deadline.value = d;
  void setCategory(String? categoryId) => selectedCategoryId.value = categoryId;

  /// Cargar categorías del curso
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final courseCategories = await _categoryService.getCategoriesByCourse(courseId);
      categories.assignAll(courseCategories);
    } catch (e) {
      print('❌ Error cargando categorías: $e');
      categories.clear();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    print('🔄 Iniciando creación de actividad...');
    
    if (!(formKey.currentState?.validate() ?? false)) {
      print('❌ Validación del formulario falló');
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
        type: 'Tarea', // Tipo fijo por ahora
        courseId: courseId,
        categoryId: selectedCategoryId.value,
      );

      print('📝 Datos de actividad a crear:');
      print('  - Título: ${activity.title}');
      print('  - Descripción: ${activity.description}');
      print('  - Curso ID: ${activity.courseId}');
      print('  - Categoría ID: ${activity.categoryId}');
      print('  - Fecha límite: ${activity.dueDate}');

      print('🚀 Llamando caso de uso...');
      await createActivityUC(activity);
      print('✅ Actividad creada exitosamente!');
      
      // Recargar actividades del curso si existe el controlador
      try {
        print('🔄 Intentando recargar actividades del curso...');
        final courseDetailController = Get.find<CourseDetailController>();
        courseDetailController.loadRobleActivities();
        print('✅ Actividades del curso recargadas');
      } catch (e) {
        print('⚠️ No se pudo recargar actividades del curso: $e');
      }
      
      // Mostrar mensaje de éxito y navegar hacia atrás
      Get.snackbar('Éxito', 'Actividad creada exitosamente',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
      
      // Pequeño delay para que el usuario vea el mensaje
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('🔙 Navegando hacia atrás...');
      try {
        Get.back();
        print('✅ Navegación exitosa');
      } catch (e) {
        print('❌ Error en navegación: $e');
        // Como alternativa, navegar al home o a una ruta específica
        Get.offAllNamed('/home');
      }
      
    } catch (e) {
      print('❌ Error creando actividad: $e');
      error.value = 'No se pudo crear la actividad: $e';
      Get.snackbar('Error', error.value!,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      print('🔄 Finalizando submit - isLoading: ${isLoading.value}');
      isLoading.value = false;
      print('✅ Submit finalizado - isLoading: ${isLoading.value}');
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
