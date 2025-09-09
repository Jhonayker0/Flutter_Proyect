import 'package:flutter_application/data/datasources/database.dart';
import 'package:sqflite/sqflite.dart';

class ActivityService {
  final DatabaseService _dbService = DatabaseService();

  /// Crear una nueva actividad
  Future<int> postActivity({
    required String nombre,
    required int categoriaId,
    required String? fechaEntrega, // ISO string o null
    required String? fechaPublicacion, // ISO string o null
  }) async {
    final db = await _dbService.database;

    final id = await db.insert('actividad', {
      'nombre': nombre,
      'categoria_id': categoriaId,
      'fecha_entrega': fechaEntrega,
      'fecha_publicacion': fechaPublicacion ?? DateTime.now().toIso8601String(),
    });

    return id;
  }

  /// Obtener todas las actividades de un curso (a través de categorías)
  Future<List<Map<String, dynamic>>> getActivitiesByCourse(int courseId) async {
    final db = await _dbService.database;

    return await db.rawQuery(
      '''
      SELECT a.*, c.nombre as categoria_nombre
      FROM actividad a
      INNER JOIN categoria c ON a.categoria_id = c.id
      WHERE c.curso_id = ?
      ORDER BY a.fecha_publicacion DESC
    ''',
      [courseId],
    );
  }

  /// Obtener actividades por categoría
  Future<List<Map<String, dynamic>>> getActivitiesByCategory(
    int categoryId,
  ) async {
    final db = await _dbService.database;

    return await db.query(
      'actividad',
      where: 'categoria_id = ?',
      whereArgs: [categoryId],
      orderBy: 'fecha_publicacion DESC',
    );
  }

  /// Actualizar actividad
  Future<int> updateActivity(int id, Map<String, dynamic> data) async {
    final db = await _dbService.database;

    return await db.update('actividad', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Eliminar actividad
  Future<int> deleteActivity(int id) async {
    final db = await _dbService.database;

    return await db.delete('actividad', where: 'id = ?', whereArgs: [id]);
  }

  /// Obtener categorías de un curso (para el dropdown)
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(int courseId) async {
    final db = await _dbService.database;

    return await db.query(
      'categoria',
      columns: ['id', 'nombre'],
      where: 'curso_id = ?',
      whereArgs: [courseId],
      orderBy: 'nombre ASC',
    );
  }
}
