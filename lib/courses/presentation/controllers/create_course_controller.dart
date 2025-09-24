import 'package:flutter/material.dart';
import 'package:flutter_application/core/presentation/controllers/home_controller_new.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/routes.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/use_cases/create_course_case.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';

class CreateCourseController extends GetxController with GetSingleTickerProviderStateMixin {
  final CreateCourse createCourseUseCase;
  CreateCourseController({required this.createCourseUseCase});

  final AuthController authController = Get.find<AuthController>();

  // Controllers para crear curso
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Controllers para unirse a curso
  final courseCodeCtrl = TextEditingController();

  // Tab controller
  late TabController tabController;

  final isLoading = false.obs;
  final isJoining = false.obs;
  final error = RxnString();
  final joinError = RxnString();

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final user = authController.currentUser.value;
    if (user == null) {
      error.value = 'Usuario no logeado';
      return;
    }

    // Usar UUID si está disponible, sino usar el id como fallback
    final professorId = user.uuid ?? user.id.toString();

    isLoading.value = true;
    error.value = null;

    try {
      print('🚀 Iniciando creación de curso desde controlador...');
      print('👤 Usuario ID: ${user.id}');
      print('🔑 Usuario UUID: ${user.uuid}');
      print('📝 Professor ID a usar: $professorId');
      print('📝 Título: ${nameCtrl.text.trim()}');
      print('📄 Descripción: ${descCtrl.text.trim()}');
      
      final course = Course(
        title: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        professorId: professorId, // Usar UUID
        role: 'Professor', // rol del creador
        createdAt: DateTime.now(),
      );
      
      print('🏗️ Objeto curso creado: ${course.toRoble()}');
      final res = await createCourseUseCase(course);
      print('📥 Resultado del caso de uso: $res');
      switch (res) {
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

          final homeController = Get.find<HomeController>();
          homeController.loadCourses();

          Get.offNamed(Routes.home);
          break;
        case Err(message: final m):
          final title = m.contains('límite máximo') ? 'Límite Alcanzado' : 'Error';
          final message = m.contains('límite máximo') ? m : 'No se pudo crear el curso: $m';
          
          Get.snackbar(
            title,
            message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            snackPosition: SnackPosition.BOTTOM,
          );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el curso $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> joinCourse() async {
    final courseCode = courseCodeCtrl.text.trim();
    if (courseCode.isEmpty) {
      joinError.value = 'Por favor ingresa el código del curso';
      return;
    }

    final userUuid = authController.currentUser.value?.uuid;
    if (userUuid == null) {
      joinError.value = 'Usuario no autenticado';
      return;
    }

    isJoining.value = true;
    joinError.value = null;

    try {
      // Verificar que el curso existe
      final coursesService = Get.find<RobleDatabaseService>();
      final courses = await coursesService.read('courses');
      final course = courses.firstWhereOrNull((c) => c['_id'] == courseCode);
      
      if (course == null) {
        joinError.value = 'Curso no encontrado. Verifica el código.';
        return;
      }

      // Verificar que no esté ya inscrito
      final enrollments = await coursesService.read('enrollments');
      final existingEnrollment = enrollments.firstWhereOrNull(
        (e) => e['student_id'] == userUuid && e['course_id'] == courseCode,
      );

      if (existingEnrollment != null) {
        joinError.value = 'Ya estás inscrito en este curso';
        return;
      }

      // Crear el enrollment
      final enrollmentData = {
        'student_id': userUuid,
        'course_id': courseCode,
        'role': 'student',
      };

      await coursesService.insert('enrollments', [enrollmentData]);

      Get.snackbar(
        'Éxito',
        'Te has unido al curso "${course['title']}" correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      courseCodeCtrl.clear();

      // Recargar cursos en el home
      final homeController = Get.find<HomeController>();
      homeController.loadCourses();

      Get.offNamed(Routes.home);

    } catch (e) {
      joinError.value = 'Error al unirse al curso: $e';
      print('❌ Error joining course: $e');
    } finally {
      isJoining.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    courseCodeCtrl.dispose();
    tabController.dispose();
    super.onClose();
  }
}
