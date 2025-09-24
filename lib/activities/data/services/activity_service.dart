import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/activities/domain/models/activity.dart';

class ActivityService {
  final RobleDatabaseService _databaseService;
  static const String tableName = 'activities';

  ActivityService(this._databaseService);

  /// Crear una nueva actividad en ROBLE
  Future<void> postActivity(Activity activity) async {
    try {
      print('🔄 Creando actividad en ROBLE...');
      print('📝 Datos: ${activity.toRoble()}');
      
      await _databaseService.insert(tableName, [activity.toRoble()]);
      print('✅ Actividad creada exitosamente');
    } catch (e) {
      print('❌ Error creando actividad: $e');
      throw Exception('Error al crear actividad: $e');
    }
  }

  /// Obtener actividades por curso
  Future<List<Activity>> getActivitiesByCourse(String courseId) async {
    try {
      final data = await _databaseService.read(tableName);
      return data
          .where((activity) => activity['course_id'] == courseId)
          .map((activityMap) => Activity.fromRoble(activityMap))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo actividades: $e');
      return [];
    }
  }

  /// Obtener actividad por ID
  Future<Activity?> getActivityById(String id) async {
    try {
      final data = await _databaseService.read(tableName);
      final activityMap = data
          .where((activity) => activity['_id'] == id)
          .firstOrNull;
      
      return activityMap != null ? Activity.fromRoble(activityMap) : null;
    } catch (e) {
      print('❌ Error obteniendo actividad: $e');
      return null;
    }
  }
}
