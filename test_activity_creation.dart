import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/activities/data/services/activity_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';

/// Archivo de prueba para validar la creación de actividades
void main() async {
  print('🧪 Iniciando prueba de creación de actividades...');

  try {
    // Configurar servicios
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final activityService = ActivityService(databaseService);

    // Crear actividad de prueba
    final testActivity = Activity(
      title: 'Actividad de Prueba',
      description: 'Esta es una actividad creada desde el nuevo sistema',
      type: 'Tarea',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      courseId: 'test-course-id',
      categoryId: 'test-category-id',
    );

    print('📝 Datos de la actividad:');
    print('  - Título: ${testActivity.title}');
    print('  - Descripción: ${testActivity.description}');
    print('  - Tipo: ${testActivity.type}');
    print('  - Fecha límite: ${testActivity.dueDate}');
    print('  - Curso ID: ${testActivity.courseId}');
    print('  - Categoría ID: ${testActivity.categoryId}');

    print('\n🔄 Creando actividad en ROBLE...');
    await activityService.postActivity(testActivity);

    print('✅ ¡Actividad creada exitosamente!');

    print('\n📚 Obteniendo actividades del curso...');
    final activities = await activityService.getActivitiesByCourse(testActivity.courseId);
    print('📊 Actividades encontradas: ${activities.length}');

    for (final activity in activities) {
      print('  - ${activity.title} (${activity.type})');
    }

  } catch (e) {
    print('❌ Error en la prueba: $e');
  }
}