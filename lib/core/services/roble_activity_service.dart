import 'roble_database_service.dart';

class RobleActivityService {
  final RobleDatabaseService _databaseService;

  RobleActivityService(this._databaseService);

  /// Obtener actividades por curso
  Future<List<Map<String, dynamic>>> getActivitiesByCourse(
    String courseId,
  ) async {
    try {
      print('📝 Buscando actividades para curso: $courseId');

      // Obtener todas las actividades
      final activities = await _databaseService.read('activities');

      if (activities.isEmpty) {
        print('📝 No hay actividades en el sistema');
        return [];
      }

      // Filtrar por curso específico
      final courseActivities = activities
          .where((activity) => activity['course_id'] == courseId)
          .toList();

      print('📝 Actividades del curso: ${courseActivities.length}');

      // Procesar las actividades para agregar información adicional
      final processedActivities = <Map<String, dynamic>>[];

      for (final activity in courseActivities) {
        final processedActivity = Map<String, dynamic>.from(activity);

        // Formatear fecha si existe
        if (processedActivity['due_date'] != null) {
          try {
            final dueDate = DateTime.parse(
              processedActivity['due_date'].toString(),
            );
            processedActivity['formatted_due_date'] =
                '${dueDate.day}/${dueDate.month}/${dueDate.year}';
            processedActivity['due_date_object'] = dueDate;
          } catch (e) {
            print('⚠️ Error procesando fecha: $e');
            processedActivity['formatted_due_date'] = 'Fecha inválida';
          }
        }

        // Obtener información de categoría si está asignada
        if (processedActivity['category_id'] != null) {
          final categoryInfo = await _getCategoryInfo(
            processedActivity['category_id'],
          );
          if (categoryInfo != null) {
            processedActivity['category_name'] = categoryInfo['name'];
            processedActivity['category_type'] = categoryInfo['type'];
          }
        }

        processedActivities.add(processedActivity);
      }

      // Ordenar por fecha de vencimiento (más próximas primero)
      processedActivities.sort((a, b) {
        final dateA = a['due_date_object'] as DateTime?;
        final dateB = b['due_date_object'] as DateTime?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateA.compareTo(dateB);
      });

      print('✅ Actividades procesadas: ${processedActivities.length}');
      return processedActivities;
    } catch (e) {
      print('❌ Error obteniendo actividades por curso: $e');
      return [];
    }
  }

  /// Obtener información de una categoría específica
  Future<Map<String, dynamic>?> _getCategoryInfo(String categoryId) async {
    try {
      final categories = await _databaseService.read('categories');
      final category = categories
          .where((cat) => cat['_id'] == categoryId)
          .firstOrNull;
      return category;
    } catch (e) {
      print('❌ Error obteniendo información de categoría: $e');
      return null;
    }
  }

  /// Obtener actividad por ID
  Future<Map<String, dynamic>?> getActivityById(String activityId) async {
    try {
      final activities = await _databaseService.read('activities');
      final activity = activities
          .where((act) => act['_id'] == activityId)
          .firstOrNull;
      return activity;
    } catch (e) {
      print('❌ Error obteniendo actividad por ID: $e');
      return null;
    }
  }

  /// Obtener estadísticas de actividades por curso
  Future<Map<String, int>> getActivityStatsByCourse(String courseId) async {
    try {
      final activities = await getActivitiesByCourse(courseId);

      final stats = <String, int>{
        'total': activities.length,
        'pending': 0,
        'overdue': 0,
        'by_type': 0,
      };

      final now = DateTime.now();

      for (final activity in activities) {
        final dueDate = activity['due_date_object'] as DateTime?;

        if (dueDate != null) {
          if (dueDate.isBefore(now)) {
            stats['overdue'] = (stats['overdue'] ?? 0) + 1;
          } else {
            stats['pending'] = (stats['pending'] ?? 0) + 1;
          }
        }
      }

      return stats;
    } catch (e) {
      print('❌ Error obteniendo estadísticas de actividades: $e');
      return {'total': 0, 'pending': 0, 'overdue': 0};
    }
  }
}
