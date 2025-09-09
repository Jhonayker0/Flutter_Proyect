import 'package:flutter_application/domain/models/course.dart';
import 'package:flutter_application/domain/models/user.dart';
import 'package:flutter_application/domain/repositories/course_repository.dart';
import 'package:flutter_application/domain/repositories/activity_repository.dart';
import 'package:get/get.dart';
import '../../domain/models/activity.dart';
import '../controllers/home_controller_new.dart';

class CourseDetailController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<User> students = <User>[].obs;
  final RxBool isLoading = false.obs;
  late Course course;
  final RxInt studentCount = 0.obs;
  final CourseRepository repo;
  final ActivityRepository activityRepo;
  CourseDetailController({required this.repo, required this.activityRepo});

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
      await Future.wait([loadActivities(), loadStudents()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActivities() async {
    try {
      isLoading.value = true;
      final courseActivities = await activityRepo.getActivitiesByCourse(
        course.id!,
      );
      activities.assignAll(courseActivities);
    } catch (e) {
      // Si hay error, mantener actividades mock para desarrollo
      final mockActivities = [
        Activity(
          id: 1,
          title: 'Tarea 1: Fundamentos',
          description: 'Completar los ejercicios del capítulo 1',
          type: 'Tarea',
          categoryId: 1, // Usar categoryId en lugar de courseId
          dueDate: DateTime.now().add(const Duration(days: 7)),
          isCompleted: false,
        ),
        Activity(
          id: 2,
          title: 'Quiz 1: Conceptos básicos',
          description: 'Evaluación de conceptos fundamentales',
          type: 'Examen',
          categoryId: 1, // Usar categoryId en lugar de courseId
          dueDate: DateTime.now().add(const Duration(days: 3)),
          isCompleted: true,
          grade: 85.0,
        ),
      ];
      activities.assignAll(mockActivities);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStudents() async {
    students.clear(); // RxList<User>
    students.assignAll(
      (await repo.getUsersByCourse(course.id!))
          .map(
            (r) => User(
              id: r['id'] as int,
              name: r['nombre'] as String,
              email: r['correo'] as String,
              imagepathh: r['imagen'] as String?, // opcional
            ),
          )
          .toList(),
    );
    studentCount.value = students.length;
  }

  void createNewActivity() {
    if (isProfessor) {
      Get.toNamed('/create-activity', arguments: {'courseId': course.id})?.then(
        (result) {
          if (result == true) {
            loadActivities(); // Recargar actividades después de crear
          }
        },
      );
    }
  }

  void createNewCategory() {
    if (isProfessor) {
      Get.toNamed('/create-category', arguments: {'courseId': course.id});
    }
  }

  void inviteStudent() {
    if (isProfessor) {
      Get.toNamed('/invite-student', arguments: {'courseId': course.id});
    }
  }

  void viewActivity(Activity activity) {
    Get.toNamed('/activity-detail', arguments: {'activity': activity});
  }

  void viewStudent(User student) {
    Get.toNamed('/student-detail', arguments: {'student': student});
  }

  void refreshData() {
    loadCourseData();
  }
}
