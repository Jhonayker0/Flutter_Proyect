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
      
      // Asignar datos raw para uso en la UI de actividades
      courseActivities.assignAll(activitiesData);
      
      // Para estudiantes, verificar qué actividades ya han sido enviadas
      List<Activity> activityObjects;
      if (!isProfessor) {
        activityObjects = await _loadActivitiesWithCompletionStatus(activitiesData);
      } else {
        // Para profesores, solo convertir los datos sin verificar completado
        activityObjects = activitiesData
            .map((data) => Activity.fromRoble(data))
            .toList();
      }
      
      activities.assignAll(activityObjects);
      activityCount.value = activitiesData.length;

      print('✅ Actividades cargadas: ${activityCount.value}');
      print('✅ Objetos Activity creados: ${activities.length}');
      if (!isProfessor) {
        final completed = activities.where((a) => a.isCompleted).length;
        final pending = activities.where((a) => !a.isCompleted).length;
        print('✅ Completadas: $completed, Pendientes: $pending');
      }
    } catch (e) {
      print('❌ Error cargando actividades: $e');
      courseActivities.clear();
      activities.clear();
      activityCount.value = 0;
    } finally {
      isLoadingActivities.value = false;
    }
  }

  /// Cargar actividades con estado de completado para estudiantes
  Future<List<Activity>> _loadActivitiesWithCompletionStatus(
      List<Map<String, dynamic>> activitiesData) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.uuid;
      
      if (currentUserId == null) {
        // Si no hay usuario, marcar todas como no completadas
        return activitiesData
            .map((data) => Activity.fromRoble(data))
            .toList();
      }

      // Obtener todas las submissions del usuario actual
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);
      final submissions = await databaseService.read('submissions');
      
      // Filtrar submissions del usuario actual
      final userSubmissions = submissions.where((submission) =>
          submission['student_id'] == currentUserId
      ).toList();
      
      // Crear set de IDs de actividades enviadas por el usuario
      final submittedActivityIds = userSubmissions
          .map((submission) => submission['activity_id'])
          .toSet();

      // Convertir actividades y marcar las completadas
      final activityObjects = activitiesData.map((data) {
        final activity = Activity.fromRoble(data);
        final activityId = activity.id;
        
        // Marcar como completada si el usuario ya envió una submission
        final isCompleted = activityId != null && 
                           submittedActivityIds.contains(activityId);
        
        return activity.copyWith(isCompleted: isCompleted);
      }).toList();

      print('✅ Estado de completado verificado para ${activityObjects.length} actividades');
      print('✅ Usuario tiene submissions para: ${submittedActivityIds.length} actividades');
      
      return activityObjects;
    } catch (e) {
      print('❌ Error verificando estado de completado: $e');
      // En caso de error, devolver actividades sin marcar como completadas
      return activitiesData
          .map((data) => Activity.fromRoble(data))
          .toList();
    }
  }

  /// Actualizar el estado de completado de una actividad específica
  void _updateActivityCompletionStatus(String activityId, bool isCompleted) {
    try {
      // Buscar la actividad en la lista y actualizar su estado
      final index = activities.indexWhere((activity) => activity.id == activityId);
      if (index != -1) {
        final updatedActivity = activities[index].copyWith(isCompleted: isCompleted);
        activities[index] = updatedActivity;
        
        final completed = activities.where((a) => a.isCompleted).length;
        final pending = activities.where((a) => !a.isCompleted).length;
        print('✅ Estado actualizado - Completadas: $completed, Pendientes: $pending');
      } else {
        print('⚠️ No se encontró la actividad con ID: $activityId');
      }
    } catch (e) {
      print('❌ Error actualizando estado de completado: $e');
    }
  }

  /// Refrescar estadísticas de actividades para estudiantes
  Future<void> refreshActivityStatistics() async {
    if (!isProfessor && courseActivities.isNotEmpty) {
      try {
        print('🔄 Refrescando estadísticas de actividades...');
        final activitiesData = courseActivities.map((activity) => activity).toList();
        final updatedActivities = await _loadActivitiesWithCompletionStatus(activitiesData);
        activities.assignAll(updatedActivities);
        
        final completed = activities.where((a) => a.isCompleted).length;
        final pending = activities.where((a) => !a.isCompleted).length;
        print('✅ Estadísticas actualizadas - Completadas: $completed, Pendientes: $pending');
      } catch (e) {
        print('❌ Error refrescando estadísticas: $e');
      }
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

      // Remover de ambas listas locales
      courseActivities.removeWhere((a) => a['_id'] == activity['_id']);
      activities.removeWhere((a) => a.id == activity['_id']);

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
        
        // Asegurar que la actividad esté marcada como completada
        _updateActivityCompletionStatus(activity['_id'], true);
        
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
        
        // Actualizar el estado de completado en la lista de actividades
        _updateActivityCompletionStatus(activity['_id'], true);
        
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

  /// Obtiene todas las submissions de una actividad para evaluación peer
  Future<List<Map<String, dynamic>>> getActivitySubmissions(String activityId) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.uuid;
      
      if (currentUserId == null) return [];

      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Obtener todas las submissions de la actividad
      final submissions = await databaseService.read('submissions');
      
      // Filtrar submissions de esta actividad, excluyendo la propia
      final activitySubmissions = submissions.where((submission) =>
          submission['activity_id'] == activityId &&
          submission['student_id'] != currentUserId
      ).toList();

      // Obtener las calificaciones ya dadas por el usuario actual
      final grades = await databaseService.read('grades');
      final myGrades = grades.where((grade) => 
          grade['graded_by'] == currentUserId
      ).toList();

      // Agregar información de calificación a cada submission
      for (var submission in activitySubmissions) {
        final existingGrade = myGrades.firstWhere(
          (grade) => grade['submission_id'] == submission['_id'],
          orElse: () => <String, dynamic>{},
        );
        
        submission['my_grade'] = existingGrade.isEmpty ? null : existingGrade['grade'];
        submission['grade_id'] = existingGrade.isEmpty ? null : existingGrade['_id'];
      }

      return activitySubmissions;
    } catch (e) {
      print('❌ Error obteniendo submissions para evaluación: $e');
      return [];
    }
  }

  /// Muestra el diálogo de evaluación de pares
  Future<void> showPeerEvaluationDialog(Map<String, dynamic> activity) async {
    try {
      isLoading.value = true;
      
      final submissions = await getActivitySubmissions(activity['_id']);
      
      if (submissions.isEmpty) {
        Get.snackbar(
          'Sin entregas',
          'No hay entregas de compañeros para evaluar en esta actividad',
          icon: Icon(Icons.info, color: Colors.white),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        AlertDialog(
          title: Text('Evaluar Compañeros'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad: ${activity['title']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Entregas de compañeros:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final hasGrade = submission['my_grade'] != null;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: hasGrade ? Colors.green : Colors.grey,
                            child: Icon(
                              hasGrade ? Icons.check : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('Estudiante: ${submission['student_id'].toString().substring(0, 8)}...'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasGrade)
                                Text(
                                  'Mi calificación: ${submission['my_grade']}/5',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _showSubmissionEvaluationDialog(submission),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar las entregas: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el diálogo para evaluar una submission específica
  Future<void> _showSubmissionEvaluationDialog(Map<String, dynamic> submission) async {
    int selectedGrade = submission['my_grade']?.toInt() ?? 3;
    
    final result = await Get.dialog<int?>(
      AlertDialog(
        title: Text('Evaluar Entrega'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Estudiante: ${submission['student_id'].toString().substring(0, 8)}...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Respuesta:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    submission['content'] ?? 'Sin respuesta',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                if (submission['file_url'] != null && submission['file_url'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'URL adjunta:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade50,
                    ),
                    child: Text(
                      submission['file_url'],
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Calificación (1-5):',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            final grade = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGrade = grade;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: selectedGrade == grade 
                                      ? Colors.blue 
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: selectedGrade == grade 
                                        ? Colors.blue.shade700 
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    grade.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: selectedGrade == grade 
                                          ? Colors.white 
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Calificación seleccionada: $selectedGrade/5',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    );
                  },
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
            onPressed: () => Get.back(result: selectedGrade),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Evaluar'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveGrade(submission, result);
    }
  }

  /// Guarda o actualiza una calificación en la tabla grades
  Future<void> _saveGrade(Map<String, dynamic> submission, int grade) async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.uuid;
      
      if (currentUserId == null) {
        throw Exception('Usuario no encontrado');
      }

      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      if (submission['grade_id'] != null) {
        // Actualizar calificación existente
        final updates = {
          'grade': grade.toDouble(),
          'max_grade': 5.0,
        };

        await databaseService.update('grades', submission['grade_id'], updates);
        
        Get.snackbar(
          'Éxito',
          'Calificación actualizada correctamente',
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        print('✅ Calificación actualizada: ${grade}/5');
      } else {
        // Crear nueva calificación
        final gradeData = {
          'submission_id': submission['_id'].toString(),
          'grade': grade.toDouble(),
          'max_grade': 5.0,
          'feedback': '',
          'graded_by': currentUserId.toString(),
        };

        await databaseService.insert('grades', [gradeData]);
        
        Get.snackbar(
          'Éxito',
          'Calificación enviada correctamente',
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        print('✅ Nueva calificación creada: ${grade}/5');
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la calificación: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error guardando calificación: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtiene todas las submissions de una actividad con notas para el profesor
  Future<List<Map<String, dynamic>>> getActivitySubmissionsForProfessor(String activityId) async {
    try {
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);

      // Obtener todas las submissions de la actividad
      final submissions = await databaseService.read('submissions');
      final activitySubmissions = submissions.where((submission) =>
          submission['activity_id'] == activityId
      ).toList();

      // Obtener todas las calificaciones
      final grades = await databaseService.read('grades');

      // Calcular promedio de notas para cada submission
      for (var submission in activitySubmissions) {
        final submissionGrades = grades.where((grade) => 
            grade['submission_id'] == submission['_id']
        ).toList();
        
        if (submissionGrades.isNotEmpty) {
          final gradeSum = submissionGrades.fold<double>(0.0, (sum, grade) => 
              sum + (grade['grade']?.toDouble() ?? 0.0));
          final averageGrade = gradeSum / submissionGrades.length;
          
          submission['average_grade'] = averageGrade;
          submission['total_evaluations'] = submissionGrades.length;
          submission['grades_list'] = submissionGrades;
        } else {
          submission['average_grade'] = null;
          submission['total_evaluations'] = 0;
          submission['grades_list'] = [];
        }
      }

      // Ordenar por promedio de nota (mayor a menor)
      activitySubmissions.sort((a, b) {
        final aGrade = a['average_grade'] ?? 0.0;
        final bGrade = b['average_grade'] ?? 0.0;
        return bGrade.compareTo(aGrade);
      });

      return activitySubmissions;
    } catch (e) {
      print('❌ Error obteniendo submissions para profesor: $e');
      return [];
    }
  }

  /// Muestra el diálogo de ver notas para el profesor
  Future<void> showGradesViewDialog(Map<String, dynamic> activity) async {
    try {
      isLoading.value = true;
      
      final submissions = await getActivitySubmissionsForProfessor(activity['_id']);
      
      if (submissions.isEmpty) {
        Get.snackbar(
          'Sin entregas',
          'No hay entregas de estudiantes en esta actividad',
          icon: Icon(Icons.info, color: Colors.white),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        AlertDialog(
          title: Text('Ver Notas'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad: ${activity['title']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Estadísticas generales
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total entregas:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${submissions.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Con evaluaciones:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${submissions.where((s) => s['total_evaluations'] > 0).length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Entregas de estudiantes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final hasGrades = submission['total_evaluations'] > 0;
                      final averageGrade = submission['average_grade'];
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: hasGrades 
                                ? (averageGrade >= 4.0 ? Colors.green : 
                                   averageGrade >= 3.0 ? Colors.orange : Colors.red)
                                : Colors.grey,
                            child: Text(
                              hasGrades 
                                  ? averageGrade.toStringAsFixed(1)
                                  : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text('Estudiante: ${submission['student_id'].toString().substring(0, 8)}...'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasGrades) ...[
                                Text(
                                  'Promedio: ${averageGrade.toStringAsFixed(2)}/5.0',
                                  style: TextStyle(
                                    color: averageGrade >= 4.0 ? Colors.green : 
                                           averageGrade >= 3.0 ? Colors.orange : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Evaluaciones: ${submission['total_evaluations']}',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Sin evaluaciones',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _showSubmissionDetailForProfessor(submission),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las notas: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el detalle de una submission para el profesor (solo lectura)
  Future<void> _showSubmissionDetailForProfessor(Map<String, dynamic> submission) async {
    final hasGrades = submission['total_evaluations'] > 0;
    final averageGrade = submission['average_grade'];
    final gradesList = submission['grades_list'] as List<dynamic>;
    
    Get.dialog(
      AlertDialog(
        title: Text('Detalle de Entrega'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Estudiante: ${submission['student_id'].toString().substring(0, 8)}...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Información de la entrega
                Text(
                  'Respuesta:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    submission['content'] ?? 'Sin respuesta',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                
                if (submission['file_url'] != null && submission['file_url'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'URL adjunta:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade50,
                    ),
                    child: Text(
                      submission['file_url'],
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Información de calificaciones
                if (hasGrades) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calificaciones:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Promedio: ${averageGrade.toStringAsFixed(2)}/5.0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Total evaluaciones: ${submission['total_evaluations']}',
                          style: TextStyle(color: Colors.green.shade600),
                        ),
                        const SizedBox(height: 12),
                        
                        // Lista de calificaciones individuales
                        Text(
                          'Calificaciones individuales:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...gradesList.map((grade) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Evaluador: ${grade['graded_by'].toString().substring(0, 8)}...',
                                style: TextStyle(fontSize: 12),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${grade['grade']}/5',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sin evaluaciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Esta entrega aún no ha sido evaluada por otros estudiantes.',
                          style: TextStyle(color: Colors.orange.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
