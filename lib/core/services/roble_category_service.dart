import 'roble_database_service.dart';

class RobleCategoryService {
  final RobleDatabaseService _databaseService;

  RobleCategoryService(this._databaseService);

  /// Obtener categorías por curso
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(
    String courseId,
  ) async {
    try {
      print('📂 Buscando categorías para curso: $courseId');

      // Obtener todas las categorías
      final categories = await _databaseService.read('categories');

      if (categories.isEmpty) {
        print('📂 No hay categorías en el sistema');
        return [];
      }

      // Filtrar por curso específico
      final courseCategories = categories
          .where((category) => category['course_id'] == courseId)
          .toList();

      print('📂 Categorías del curso: ${courseCategories.length}');

      // Procesar las categorías para agregar información adicional
      final processedCategories = <Map<String, dynamic>>[];

      for (final category in courseCategories) {
        final processedCategory = Map<String, dynamic>.from(category);

        // Obtener estadísticas de actividades en esta categoría
        final activityStats = await _getActivityStatsForCategory(
          category['_id'],
        );
        processedCategory['activity_count'] = activityStats['count'];
        processedCategory['pending_activities'] = activityStats['pending'];
        processedCategory['overdue_activities'] = activityStats['overdue'];

        // Obtener estadísticas de grupos en esta categoría
        final groupStats = await _getGroupStatsForCategory(category['_id']);
        processedCategory['group_count'] = groupStats['count'];
        processedCategory['total_members'] = groupStats['members'];

        processedCategories.add(processedCategory);
      }

      // Ordenar por nombre
      processedCategories.sort((a, b) {
        final nameA = (a['name'] ?? '').toString().toLowerCase();
        final nameB = (b['name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      print('✅ Categorías procesadas: ${processedCategories.length}');
      return processedCategories;
    } catch (e) {
      print('❌ Error obteniendo categorías por curso: $e');
      return [];
    }
  }

  /// Obtener estadísticas de grupos para una categoría específica
  Future<Map<String, int>> _getGroupStatsForCategory(String categoryId) async {
    try {
      final groups = await _databaseService.read('groups');
      final categoryGroups = groups
          .where((group) => group['category_id'] == categoryId)
          .toList();

      int totalMembers = 0;

      // Contar miembros en todos los grupos de esta categoría
      for (final group in categoryGroups) {
        final members = await _getGroupMembers(group['_id']);
        totalMembers += members.length;
      }

      return {'count': categoryGroups.length, 'members': totalMembers};
    } catch (e) {
      print('❌ Error obteniendo estadísticas de grupos para categoría: $e');
      return {'count': 0, 'members': 0};
    }
  }

  /// Obtener miembros de un grupo específico
  Future<List<Map<String, dynamic>>> _getGroupMembers(String groupId) async {
    try {
      final groupMembers = await _databaseService.read('group_members');
      return groupMembers
          .where((member) => member['group_id'] == groupId)
          .toList();
    } catch (e) {
      print('❌ Error obteniendo miembros del grupo: $e');
      return [];
    }
  }

  /// Obtener estadísticas de actividades para una categoría específica
  Future<Map<String, int>> _getActivityStatsForCategory(
    String categoryId,
  ) async {
    try {
      final activities = await _databaseService.read('activities');
      final categoryActivities = activities
          .where((activity) => activity['category_id'] == categoryId)
          .toList();

      final stats = <String, int>{
        'count': categoryActivities.length,
        'pending': 0,
        'overdue': 0,
      };

      final now = DateTime.now();

      for (final activity in categoryActivities) {
        if (activity['due_date'] != null) {
          try {
            final dueDate = DateTime.parse(activity['due_date'].toString());
            if (dueDate.isBefore(now)) {
              stats['overdue'] = (stats['overdue'] ?? 0) + 1;
            } else {
              stats['pending'] = (stats['pending'] ?? 0) + 1;
            }
          } catch (e) {
            // Si hay error parseando la fecha, se considera pendiente
            stats['pending'] = (stats['pending'] ?? 0) + 1;
          }
        } else {
          // Sin fecha = pendiente
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      print(
        '❌ Error obteniendo estadísticas de actividades para categoría: $e',
      );
      return {'count': 0, 'pending': 0, 'overdue': 0};
    }
  }

  /// Obtener categoría por ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final categories = await _databaseService.read('categories');
      final category = categories
          .where((cat) => cat['_id'] == categoryId)
          .firstOrNull;
      return category;
    } catch (e) {
      print('❌ Error obteniendo categoría por ID: $e');
      return null;
    }
  }

  /// Obtener actividades de una categoría específica
  Future<List<Map<String, dynamic>>> getActivitiesInCategory(
    String categoryId,
  ) async {
    try {
      final activities = await _databaseService.read('activities');
      final categoryActivities = activities
          .where((activity) => activity['category_id'] == categoryId)
          .toList();

      // Procesar fechas para ordenamiento
      for (final activity in categoryActivities) {
        if (activity['due_date'] != null) {
          try {
            final dueDate = DateTime.parse(activity['due_date'].toString());
            activity['due_date_object'] = dueDate;
            activity['formatted_due_date'] =
                '${dueDate.day}/${dueDate.month}/${dueDate.year}';
          } catch (e) {
            activity['formatted_due_date'] = 'Fecha inválida';
          }
        }
      }

      // Ordenar por fecha de vencimiento
      categoryActivities.sort((a, b) {
        final dateA = a['due_date_object'] as DateTime?;
        final dateB = b['due_date_object'] as DateTime?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateA.compareTo(dateB);
      });

      return categoryActivities;
    } catch (e) {
      print('❌ Error obteniendo actividades de categoría: $e');
      return [];
    }
  }

  /// Obtener grupos de una categoría específica con sus miembros
  Future<List<Map<String, dynamic>>> getGroupsInCategory(
    String categoryId,
  ) async {
    try {
      print('🔍 Buscando grupos para categoría ID: $categoryId');
      
      final groups = await _databaseService.read('groups');
      print('🔍 Total grupos en base de datos: ${groups.length}');
      
      if (groups.isNotEmpty) {
        print('🔍 Primer grupo ejemplo: ${groups.first}');
        print('🔍 Estructura de category_id en primer grupo: ${groups.first['category_id']}');
      }
      
      final categoryGroups = groups
          .where((group) => group['category_id'] == categoryId)
          .toList();
          
      print('🔍 Grupos encontrados para categoría $categoryId: ${categoryGroups.length}');
      
      if (categoryGroups.isEmpty) {
        print('❌ No se encontraron grupos. Verificando todos los category_id:');
        for (var group in groups) {
          print('   - Grupo: ${group['name']} | category_id: ${group['category_id']} | Comparando con: $categoryId');
        }
        return [];
      }

      // Procesar cada grupo para agregar información de miembros
      final processedGroups = <Map<String, dynamic>>[];

      for (final group in categoryGroups) {
        final processedGroup = Map<String, dynamic>.from(group);

        // Obtener miembros del grupo
        final members = await _getGroupMembers(group['_id']);
        processedGroup['members'] = members;
        processedGroup['member_count'] = members.length;

        // Obtener información de usuarios para cada miembro
        final memberDetails = <Map<String, dynamic>>[];
        for (final member in members) {
          final studentId = member['student_id'];
          // Aquí podrías obtener más información del usuario si es necesario
          memberDetails.add({
            '_id': member['_id'],
            'group_id': member['group_id'],
            'student_id': studentId,
            'student_uuid': studentId, // Asumiendo que student_id es el UUID
          });
        }
        processedGroup['member_details'] = memberDetails;

        // Calcular porcentaje de capacidad utilizada
        final capacity = processedGroup['capacity'] as int? ?? 0;
        final memberCount = processedGroup['member_count'] as int? ?? 0;
        if (capacity > 0) {
          processedGroup['capacity_percentage'] =
              ((memberCount / capacity) * 100).round();
        }

        processedGroups.add(processedGroup);
      }

      // Ordenar por nombre
      processedGroups.sort((a, b) {
        final nameA = (a['name'] ?? '').toString().toLowerCase();
        final nameB = (b['name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      return processedGroups;
    } catch (e) {
      print('❌ Error obteniendo grupos de categoría: $e');
      return [];
    }
  }

  /// Obtener resumen de categorías por tipo
  Future<Map<String, int>> getCategorySummaryByCourse(String courseId) async {
    try {
      final categories = await getCategoriesByCourse(courseId);

      final summary = <String, int>{};

      for (final category in categories) {
        final type = (category['type'] ?? 'Sin tipo').toString();
        summary[type] = (summary[type] ?? 0) + 1;
      }

      return summary;
    } catch (e) {
      print('❌ Error obteniendo resumen de categorías: $e');
      return {};
    }
  }
}
