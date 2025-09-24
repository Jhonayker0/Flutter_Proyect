import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';

class CategoryService {
  late final RobleDatabaseService _dbService;
  
  CategoryService() {
    _dbService = RobleDatabaseService(RobleHttpService());
  }
  
  // Crear categoría según el esquema de la base de datos
  Future<void> postCategory({
    required String nombre,
    required String tipo, // 'aleatorio' | 'eleccion'
    required String? descripcion,
    required String cursoId,
  }) async {
    try {
      // Crear la categoría en la tabla 'categories' con los campos correctos
      final categoryData = {
        'name': nombre,
        'description': descripcion ?? '',
        'type': tipo,
        'course_id': cursoId,
      };
      
      // El servicio insert espera una lista de registros
      await _dbService.insert('categories', [categoryData]);
      
      print('✅ Categoría creada exitosamente');
    } catch (e) {
      print('❌ Error creando categoría: $e');
      throw Exception('Error al crear categoría: $e');
    }
  }

  // Obtener todas las categorías de un curso
  Future<List<Map<String, Object?>>> getAllCategoriesByCourse(
    String courseId,
  ) async {
    try {
      final allCategories = await _dbService.read('categories');
      // Filtrar por course_id
      return allCategories
          .where((category) => category['course_id'] == courseId)
          .toList();
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // Obtener categoría por ID
  Future<Map<String, Object?>?> getCategoryById(String id) async {
    try {
      final allCategories = await _dbService.read('categories');
      // Buscar por ID
      for (final category in allCategories) {
        if (category['id'] == id) {
          return category;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo categoría: $e');
      throw Exception('Error al obtener categoría: $e');
    }
  }

  // Actualizar categoría
  Future<void> updateCategory(
    String id, {
    String? nombre,
    String? tipo,
    String? descripcion,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nombre != null) updates['name'] = nombre;
      if (tipo != null) updates['type'] = tipo;
      if (descripcion != null) updates['description'] = descripcion;

      if (updates.isNotEmpty) {
        await _dbService.update('categories', id, updates);
        print('✅ Categoría actualizada exitosamente');
      }
    } catch (e) {
      print('❌ Error actualizando categoría: $e');
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  // Eliminar categoría
  Future<void> deleteCategory(String id) async {
    try {
      await _dbService.delete('categories', id);
      print('✅ Categoría eliminada exitosamente');
    } catch (e) {
      print('❌ Error eliminando categoría: $e');
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}
