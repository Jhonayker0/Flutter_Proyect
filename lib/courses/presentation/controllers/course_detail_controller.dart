import 'package:flutter_application/courses/domain/models/course.dart';
import 'package:flutter_application/auth/domain/models/user.dart';
import 'package:flutter_application/courses/domain/repositories/course_repository.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_user_service.dart';
import 'package:flutter_application/core/services/roble_activity_service.dart';
import 'package:flutter_application/core/services/roble_category_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/core/presentation/controllers/home_controller_new.dart';

class CourseDetailController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<Map<String, dynamic>> courseUsers =
      <Map<String, dynamic>>[].obs; // Usuarios con roles
  final RxList<User> students = <User>[].obs; // Mantener para compatibilidad

  // Nuevas listas para actividades y categorías
  final RxList<Map<String, dynamic>> courseActivities =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> courseCategories =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingActivities = false.obs;
  final RxBool isLoadingCategories = false.obs;

  late Course course;
  final RxInt studentCount = 0.obs;
  final RxInt activityCount = 0.obs;
  final RxInt categoryCount = 0.obs;

  final CourseRepository repo;
  late final RobleUserService _userService;
  late final RobleActivityService _activityService;
  late final RobleCategoryService _categoryService;

  CourseDetailController({required this.repo}) {
    // Inicializar los servicios de ROBLE
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    _userService = RobleUserService(databaseService);
    _activityService = RobleActivityService(databaseService);
    _categoryService = RobleCategoryService(databaseService);
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
        loadRobleActivities(),
        loadRobleCategories(),
        loadStudents(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar actividades usando ROBLE API
  Future<void> loadRobleActivities() async {
    try {
      isLoadingActivities.value = true;
      print('🔄 Cargando actividades para curso: ${course.id}');

      final activitiesData = await _activityService.getActivitiesByCourse(
        course.id ?? '',
      );
      courseActivities.assignAll(activitiesData);
      activityCount.value = activitiesData.length;

      print('✅ Actividades cargadas: ${activityCount.value}');
    } catch (e) {
      print('❌ Error cargando actividades: $e');
      courseActivities.clear();
      activityCount.value = 0;
    } finally {
      isLoadingActivities.value = false;
    }
  }

  /// Cargar categorías usando ROBLE API
  Future<void> loadRobleCategories() async {
    try {
      isLoadingCategories.value = true;
      print('🔄 Cargando categorías para curso: ${course.id}');

      final categoriesData = await _categoryService.getCategoriesByCourse(
        course.id ?? '',
      );
      courseCategories.assignAll(categoriesData);
      categoryCount.value = categoriesData.length;

      print('✅ Categorías cargadas: ${categoryCount.value}');
    } catch (e) {
      print('❌ Error cargando categorías: $e');
      courseCategories.clear();
      categoryCount.value = 0;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> loadStudents() async {
    try {
      print('🔄 Cargando estudiantes para curso: ${course.id}');
      students.clear();
      courseUsers.clear();

      // Usar ROBLE para obtener usuarios con roles
      final usersWithRoles = await _userService.getUsersByCourse(
        course.id ?? '',
      );
      courseUsers.assignAll(usersWithRoles);

      // Mantener compatibilidad con students (sin roles)
      students.assignAll(
        usersWithRoles
            .map(
              (userData) => User(
                id: userData['_id'].hashCode.abs(),
                name: userData['name'] as String,
                email: userData['email'] as String,
                imagepathh: userData['avatarUrl'] as String?,
                uuid: userData['_id'] as String,
              ),
            )
            .toList(),
      );

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
    print('🎯 createNewActivity llamado - isProfessor: $isProfessor');
    if (isProfessor) {
      print('🚀 Navegando a crear actividad con courseId: ${course.id}');
      Get.toNamed('/create-activity', arguments: {'courseId': course.id});
    } else {
      print('❌ Usuario no es profesor, no puede crear actividades');
    }
  }

  void createNewCategory() {
    if (isProfessor) {
      Get.toNamed('/create-category', arguments: {'courseId': course.id});
    }
  }

  void inviteStudent() {
    if (isProfessor) {
      _showCourseCodeDialog();
    }
  }

  void _showCourseCodeDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.share,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Código del Curso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparte este código con los estudiantes para que puedan unirse al curso:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código del curso:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.id ?? 'ID no disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyCourseCode(),
                    icon: Icon(
                      Icons.copy,
                      color: Colors.blue,
                    ),
                    tooltip: 'Copiar código',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los estudiantes podrán usar este código para inscribirse al curso.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _copyCourseCode(),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copiar Código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _copyCourseCode() async {
    try {
      final courseId = course.id;
      if (courseId == null) {
        Get.snackbar(
          'Error',
          'El ID del curso no está disponible',
          icon: Icon(Icons.error, color: Colors.white),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      await Clipboard.setData(ClipboardData(text: courseId));
      Get.back(); // Cerrar el dialog
      
      Get.snackbar(
        'Código Copiado',
        'El código del curso ha sido copiado al portapapeles',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo copiar el código. Inténtalo de nuevo.',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void viewActivity(Activity activity) {
    // Get.toNamed('/activity-detail', arguments: {'activity': activity});
    Get.snackbar(
      'En desarrollo',
      'El detalle de actividades está en desarrollo',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void viewStudent(User student) {
    // Get.toNamed('/student-detail', arguments: {'student': student});
    Get.snackbar(
      'En desarrollo',
      'El detalle de estudiantes está en desarrollo',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void leaveCourse() async {
    if (isProfessor) {
      Get.snackbar(
        'No permitido',
        'Los profesores no pueden salir de sus cursos',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Salir del Curso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres salir de "${course.title}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ten en cuenta:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Perderás acceso a todas las actividades\n'
                    '• Se eliminará tu progreso del curso\n'
                    '• Necesitarás un nuevo código para volver',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir del Curso'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await _performLeaveCourse();
    }
  }

  Future<void> _performLeaveCourse() async {
    try {
      isLoading.value = true;

      // Obtener el ID del usuario actual
      final userUuid = Get.find<AuthController>().currentUser.value?.uuid;
      if (userUuid == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener servicios
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Buscar el enrollment
      final enrollments = await databaseService.read('enrollments');
      final enrollment = enrollments.firstWhereOrNull(
        (e) => e['student_id'] == userUuid && e['course_id'] == course.id,
      );

      if (enrollment == null) {
        throw Exception('No se encontró la inscripción al curso');
      }

      // Eliminar el enrollment
      await databaseService.delete('enrollments', enrollment['_id']);

      Get.snackbar(
        'Éxito',
        'Has salido del curso "${course.title}" correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Recargar cursos en el home
      final homeController = Get.find<HomeController>();
      homeController.loadCourses();

      // Volver al home
      Get.offNamed('/home');

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo salir del curso: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error leaving course: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    loadCourseData();
  }

  /// Eliminar curso (solo para profesores)
  void deleteCourse() async {
    if (!isProfessor) {
      Get.snackbar(
        'No permitido',
        'Solo los profesores pueden eliminar cursos',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await _showDeleteCourseDialog();
    
    if (confirmed == true) {
      await _performDeleteCourse();
    }
  }

  Future<bool?> _showDeleteCourseDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Curso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar "${course.title}" permanentemente?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Esta acción es irreversible:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Se eliminarán todas las actividades\n'
                    '• Se perderá el progreso de los estudiantes\n'
                    '• Se eliminarán todas las inscripciones\n'
                    '• Esta acción no se puede deshacer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Curso'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performDeleteCourse() async {
    try {
      isLoading.value = true;

      // Obtener servicios
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Eliminar el curso de la base de datos
      await databaseService.delete('courses', course.id!);

      // También eliminar todos los enrollments relacionados
      final enrollments = await databaseService.read('enrollments');
      final courseEnrollments = enrollments
          .where((e) => e['course_id'] == course.id)
          .toList();

      for (final enrollment in courseEnrollments) {
        await databaseService.delete('enrollments', enrollment['_id']);
      }

      Get.snackbar(
        'Éxito',
        'El curso "${course.title}" ha sido eliminado correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Recargar cursos en el home
      final homeController = Get.find<HomeController>();
      homeController.loadCourses();

      // Volver al home
      Get.offNamed('/home');

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el curso: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error deleting course: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Elimina una actividad de la base de datos
  Future<void> deleteActivity(Map<String, dynamic> activity) async {
    try {
      isLoading.value = true;

      // Confirmar eliminación con diálogo
      bool confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar la actividad "${activity['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirmed) {
        isLoading.value = false;
        return;
      }

      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Eliminar la actividad de la base de datos
      await databaseService.delete('activities', activity['_id']);

      // Remover de la lista local
      courseActivities.removeWhere((a) => a['_id'] == activity['_id']);

      // Actualizar contador
      activityCount.value = courseActivities.length;

      Get.snackbar(
        'Éxito',
        'La actividad "${activity['title']}" ha sido eliminada correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      print('✅ Actividad eliminada: ${activity['title']}');

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la actividad: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error deleting activity: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtiene la respuesta existente de un estudiante para una actividad
  Future<Map<String, dynamic>?> getExistingSubmission(String activityId) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.uuid;
      
      if (currentUserId == null) return null;

      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Obtener todas las submissions
      final submissions = await databaseService.read('submissions');
      
      // Buscar la submission del estudiante para esta actividad
      final existingSubmission = submissions.firstWhere(
        (submission) =>
            submission['activity_id'] == activityId &&
            submission['student_id'] == currentUserId,
        orElse: () => <String, dynamic>{},
      );

      return existingSubmission.isEmpty ? null : existingSubmission;
    } catch (e) {
      print('❌ Error obteniendo submission existente: $e');
      return null;
    }
  }

  /// Responde o actualiza la respuesta de una actividad
  Future<void> respondToActivity(
    Map<String, dynamic> activity,
    String content,
    String? fileUrl,
  ) async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.uuid;
      
      if (currentUserId == null) {
        throw Exception('Usuario no encontrado');
      }

      // Verificar si la fecha límite no ha pasado
      final dueDateStr = activity['due_date'] as String?;
      if (dueDateStr != null) {
        final dueDate = DateTime.parse(dueDateStr);
        final now = DateTime.now();
        
        if (now.isAfter(dueDate)) {
          Get.snackbar(
            'Fecha límite vencida',
            'No puedes responder esta actividad porque la fecha límite ha pasado',
            icon: Icon(Icons.access_time, color: Colors.white),
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }

      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Verificar si ya existe una respuesta
      final existingSubmission = await getExistingSubmission(activity['_id']);
      
      if (existingSubmission != null) {
        // Actualizar respuesta existente
        final updates = {
          'content': content,
          'file_url': fileUrl ?? '',
          'status': 'delivered',
        };

        await databaseService.update('submissions', existingSubmission['_id'], updates);
        
        Get.snackbar(
          'Éxito',
          'Tu respuesta ha sido actualizada correctamente',
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        print('✅ Respuesta actualizada para actividad: ${activity['title']}');
      } else {
        // Crear nueva respuesta
        final submissionData = {
          'activity_id': activity['_id'].toString(),
          'student_id': currentUserId.toString(),
          'group_id': activity['category_id'].toString(),
          'content': content,
          'file_url': fileUrl ?? '',
          'status': 'delivered',
        };

        await databaseService.insert('submissions', [submissionData]);
        
        Get.snackbar(
          'Éxito',
          'Tu respuesta ha sido enviada correctamente',
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        print('✅ Nueva respuesta creada para actividad: ${activity['title']}');
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar la respuesta: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error respondiendo actividad: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el diálogo para responder una actividad
  Future<void> showResponseDialog(Map<String, dynamic> activity) async {
    // Verificar si la fecha límite no ha pasado
    final dueDateStr = activity['due_date'] as String?;
    if (dueDateStr != null) {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      
      if (now.isAfter(dueDate)) {
        Get.snackbar(
          'Fecha límite vencida',
          'No puedes responder esta actividad porque la fecha límite ha pasado',
          icon: Icon(Icons.access_time, color: Colors.white),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // Obtener respuesta existente si la hay
    final existingSubmission = await getExistingSubmission(activity['_id']);
    
    // Crear controladores dentro del diálogo
    TextEditingController? contentController;
    TextEditingController? urlController;
    
    try {
      contentController = TextEditingController(
        text: existingSubmission?['content'] ?? '',
      );
      urlController = TextEditingController(
        text: existingSubmission?['file_url'] ?? '',
      );

      final result = await Get.dialog<Map<String, String>?>(
        AlertDialog(
          title: Text('Responder Actividad'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad: ${activity['title']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Respuesta *',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta aquí...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'URL (Opcional)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: 'https://ejemplo.com/archivo',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final content = contentController!.text.trim();
                
                if (content.isEmpty) {
                  Get.snackbar(
                    'Campo requerido',
                    'La respuesta es obligatoria',
                    icon: Icon(Icons.error, color: Colors.white),
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final fileUrl = urlController!.text.trim();
                
                Get.back(result: {
                  'content': content,
                  'fileUrl': fileUrl,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Enviar'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      // Si el usuario envió los datos, procesar la respuesta
      if (result != null) {
        await respondToActivity(
          activity,
          result['content']!,
          result['fileUrl']!.isEmpty ? null : result['fileUrl'],
        );
      }
    } finally {
      // Siempre dispose de los controladores, sin importar qué pase
      contentController?.dispose();
      urlController?.dispose();
    }
  }
}
