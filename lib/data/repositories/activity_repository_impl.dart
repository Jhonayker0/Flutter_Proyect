import 'package:flutter_application/data/services/activity_service.dart';
import 'package:flutter_application/domain/models/activity.dart';
import 'package:flutter_application/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityService service;
  ActivityRepositoryImpl(this.service);

  @override
  Future<void> create(Activity activity) async {
    await service.postActivity(
      nombre: activity.title,
      categoriaId: activity.categoryId,
      fechaEntrega: activity.dueDate.toIso8601String(),
      fechaPublicacion: activity.createdAt.toIso8601String(),
    );
  }

  @override
  Future<List<Activity>> getActivitiesByCourse(int courseId) async {
    final rows = await service.getActivitiesByCourse(courseId);
    return rows.map(_fromDb).toList();
  }

  @override
  Future<List<Activity>> getActivitiesByCategory(int categoryId) async {
    final rows = await service.getActivitiesByCategory(categoryId);
    return rows.map(_fromDb).toList();
  }

  @override
  Future<void> update(Activity activity) async {
    if (activity.id == null)
      throw Exception('Activity ID is required for update');

    await service.updateActivity(activity.id!, {
      'nombre': activity.title,
      'categoria_id': activity.categoryId,
      'fecha_entrega': activity.dueDate.toIso8601String(),
    });
  }

  @override
  Future<void> delete(int id) async {
    await service.deleteActivity(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(int courseId) async {
    return await service.getCategoriesByCourse(courseId);
  }

  // Mapear fila DB -> dominio
  Activity _fromDb(Map<String, Object?> row) {
    return Activity(
      id: row['id'] as int?,
      title: (row['nombre'] as String?) ?? '',
      description: 'Actividad', // La BD no tiene descripción, usar default
      type: 'Tarea', // Tipo por defecto
      categoryId: (row['categoria_id'] as int?) ?? 0,
      dueDate: _parseDate(row['fecha_entrega'] as String?),
      createdAt: _parseDate(row['fecha_publicacion'] as String?),
    );
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
