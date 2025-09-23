import 'package:flutter_application/courses/domain/models/course.dart';
import 'package:flutter_application/auth/domain/models/user.dart';
import 'package:flutter_application/courses/domain/repositories/course_repository.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_user_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/core/presentation/controllers/home_controller_new.dart';

class CourseDetailController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<Map<String, dynamic>> courseUsers = <Map<String, dynamic>>[].obs; // Cambiar para incluir roles
  final RxList<User> students = <User>[].obs; // Mantener para compatibilidad
  final RxBool isLoading = false.obs;
  late Course course;
  final RxInt studentCount = 0.obs;
  final CourseRepository repo;
  late final RobleUserService _userService;
  
  CourseDetailController({required this.repo}) {
    // Inicializar el servicio de usuarios de ROBLE
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    _userService = RobleUserService(databaseService);
  }
  
  String get userRole => course.role;
  bool get isProfessor => userRole == HomeController.roleProfessor;

  @override
  void onInit() {
    super.onInit();
    // Obtener el curso desde los argumentos
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['course'] != null) {
      course = arguments['course'] as Course;
      loadCourseData();
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  String get currentTitle {
    switch (currentTabIndex.value) {
      case 0:
        return 'Actividades';
      case 1:
        return 'Estudiantes';
      case 2:
        return 'Categoria';
      case 3:
        return 'Información';
      default:
        return 'Actividades';
    }
  }

  Future<void> loadCourseData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadActivities(),
        loadStudents(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActivities() async {
    // Simular datos de actividades
    await Future.delayed(const Duration(milliseconds: 500));
    final courseIdInt = int.tryParse(course.id!) ?? 1; // Convertir String a int para compatibilidad
    final mockActivities = [
      Activity(
        id: 1,
        title: 'Tarea 1: Fundamentos',
        description: 'Completar los ejercicios del capítulo 1',
        type: 'Tarea',
        courseId: courseIdInt,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        isCompleted: false,
      ),
      Activity(
        id: 2,
        title: 'Quiz 1: Conceptos básicos',
        description: 'Evaluación de conceptos fundamentales',
        type: 'Examen',
        courseId: courseIdInt,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isCompleted: true,
        grade: 85.0,
      ),
      Activity(
        id: 3,
        title: 'Proyecto Final',
        description: 'Desarrollo de un proyecto completo aplicando todos los conceptos',
        type: 'Proyecto',
        courseId: courseIdInt,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        isCompleted: false,
      ),
    ];
    activities.assignAll(mockActivities);
  }

  Future<void> loadStudents() async {
    try {
      print('🔄 Cargando estudiantes para curso: ${course.id}');
      students.clear();
      courseUsers.clear();
      
      // Usar ROBLE para obtener usuarios con roles
      final usersWithRoles = await _userService.getUsersByCourse(course.id ?? '');
      courseUsers.assignAll(usersWithRoles);
      
      // Mantener compatibilidad con students (sin roles)
      students.assignAll(usersWithRoles.map((userData) => User(
        id: userData['_id'].hashCode.abs(),
        name: userData['name'] as String,
        email: userData['email'] as String,
        imagepathh: userData['avatarUrl'] as String?,
        uuid: userData['_id'] as String,
      )).toList());
      
      studentCount.value = courseUsers.length;
      print('✅ Estudiantes cargados: ${studentCount.value}');
    } catch (e) {
      print('❌ Error cargando estudiantes: $e');
      students.clear();
      courseUsers.clear();
      studentCount.value = 0;
    }
  }


  void createNewActivity() {
    if (isProfessor) {
      Get.toNamed('/create-activity', arguments: {'courseId': course.id});
    }
  }
  
  void createNewCategory() {
    if (isProfessor) {
      Get.toNamed('/create-category', arguments: {'courseId': course.id});
    }
  }

  void inviteStudent() {
    if (isProfessor) {
      // Get.toNamed('/invite-student', arguments: {'courseId': course.id});
      Get.snackbar('En desarrollo', 'La funcionalidad de invitar estudiantes está en desarrollo',
        backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void viewActivity(Activity activity) {
    // Get.toNamed('/activity-detail', arguments: {'activity': activity});
    Get.snackbar('En desarrollo', 'El detalle de actividades está en desarrollo',
      backgroundColor: Colors.orange, colorText: Colors.white);
  }

  void viewStudent(User student) {
    // Get.toNamed('/student-detail', arguments: {'student': student});
    Get.snackbar('En desarrollo', 'El detalle de estudiantes está en desarrollo',
      backgroundColor: Colors.orange, colorText: Colors.white);
  }

  void refreshData() {
    loadCourseData();
  }
}







