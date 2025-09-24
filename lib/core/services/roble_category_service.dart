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

      // Filtrar por curso específico con limpieza de IDs
      final courseCategories = categories
          .where((category) {
            final categoryId = category['course_id']?.toString().trim() ?? '';
            final cleanCourseId = courseId.trim();
            return categoryId == cleanCourseId;
          })
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

  /// Crear un nuevo grupo
  Future<Map<String, dynamic>?> createGroup({
    required String categoryId,
    required String name,
    required int capacity,
    String? description,
  }) async {
    try {
      print('🆕 Creando grupo: $name en categoría $categoryId');
      
      final groupData = {
        'category_id': categoryId,
        'name': name,
        'capacity': capacity,
        if (description != null && description.isNotEmpty) 'description': description,
      };
      
      await _databaseService.insert('groups', [groupData]);
      print('✅ Grupo creado');
      
      // Obtener el grupo recién creado (simplificado por ahora)
      final groups = await _databaseService.read('groups');
      final newGroup = groups.where((g) => 
        g['category_id'] == categoryId && 
        g['name'] == name
      ).last;
      
      // Si es categoría aleatoria, asignar estudiantes automáticamente
      await _assignStudentsIfRandom(categoryId, newGroup['_id']);
      
      return newGroup;
    } catch (e) {
      print('❌ Error creando grupo: $e');
      return null;
    }
  }

  /// Actualizar un grupo existente
  Future<bool> updateGroup({
    required String groupId,
    String? name,
    int? capacity,
    String? description,
  }) async {
    try {
      print('✏️ Actualizando grupo: $groupId');
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (capacity != null) updateData['capacity'] = capacity;
      if (description != null) updateData['description'] = description;
      
      await _databaseService.update('groups', groupId, updateData);
      print('✅ Grupo actualizado');
      
      return true;
    } catch (e) {
      print('❌ Error actualizando grupo: $e');
      return false;
    }
  }

  /// Eliminar un grupo
  Future<bool> deleteGroup(String groupId) async {
    try {
      print('🗑️ Eliminando grupo: $groupId');
      
      // Primero eliminar todos los miembros
      final members = await _getGroupMembers(groupId);
      for (final member in members) {
        await _databaseService.delete('group_members', member['_id']);
      }
      
      // Luego eliminar el grupo
      await _databaseService.delete('groups', groupId);
      print('✅ Grupo eliminado');
      
      return true;
    } catch (e) {
      print('❌ Error eliminando grupo: $e');
      return false;
    }
  }

  /// Añadir estudiante a grupo
  Future<bool> addStudentToGroup({
    required String groupId,
    required String studentId,
    required String categoryId,
  }) async {
    try {
      print('👥 Añadiendo estudiante $studentId al grupo $groupId');
      
      // Verificar que el estudiante no esté ya en otro grupo de esta categoría
      final existingMembership = await _getStudentGroupInCategory(studentId, categoryId);
      if (existingMembership != null) {
        print('❌ El estudiante ya está en otro grupo de esta categoría');
        return false;
      }
      
      // Verificar capacidad del grupo
      final group = await _getGroupById(groupId);
      if (group == null) return false;
      
      final currentMembers = await _getGroupMembers(groupId);
      if (currentMembers.length >= group['capacity']) {
        print('❌ El grupo está lleno');
        return false;
      }
      
      // Añadir estudiante
      await _databaseService.insert('group_members', [{
        'group_id': groupId,
        'student_id': studentId,
      }]);
      
      print('✅ Estudiante añadido al grupo');
      return true;
    } catch (e) {
      print('❌ Error añadiendo estudiante al grupo: $e');
      return false;
    }
  }

  /// Remover estudiante del grupo
  Future<bool> removeStudentFromGroup({
    required String studentId,
    required String categoryId,
  }) async {
    try {
      print('👥 Removiendo estudiante $studentId de grupo en categoría $categoryId');
      
      final membership = await _getStudentGroupInCategory(studentId, categoryId);
      if (membership == null) {
        print('❌ El estudiante no está en ningún grupo de esta categoría');
        return false;
      }
      
      await _databaseService.delete('group_members', membership['_id']);
      print('✅ Estudiante removido del grupo');
      
      return true;
    } catch (e) {
      print('❌ Error removiendo estudiante del grupo: $e');
      return false;
    }
  }

  /// Obtener estudiantes disponibles para añadir a un grupo
  Future<List<Map<String, dynamic>>> getAvailableStudents({
    required String categoryId,
    required String courseId,
  }) async {
    try {
      print('🔍 Buscando estudiantes disponibles - CategoryID: $categoryId, CourseID: $courseId');
      
      // Obtener todos los estudiantes del curso
      final enrollments = await _databaseService.read('enrollments');
      print('🔍 Total enrollments: ${enrollments.length}');
      
      final courseStudents = enrollments
          .where((e) {
            final courseMatches = e['course_id']?.toString().trim() == courseId.trim();
            final role = e['role']?.toString().toLowerCase() ?? '';
            final roleMatches = role == 'student' || role == 'estudiante';
            final matches = courseMatches && roleMatches;
            
            print('🔍 Enrollment: CourseID=${e['course_id']}, Role=${e['role']}, StudentID=${e['student_id']}');
            print('🔍 Course match: $courseMatches, Role match: $roleMatches, Final: $matches');
            
            if (matches) {
              print('🎓 Estudiante encontrado: ${e['student_id']} - Role: ${e['role']}');
            }
            return matches;
          })
          .toList();
      
      print('🎓 Estudiantes del curso: ${courseStudents.length}');

      // Obtener estudiantes que ya están en grupos de esta categoría
      final groups = await _databaseService.read('groups');
      final categoryGroups = groups.where((g) => g['category_id'] == categoryId).toList();
      print('👥 Grupos en esta categoría: ${categoryGroups.length}');
      
      final occupiedStudents = <String>{};
      for (final group in categoryGroups) {
        final members = await _getGroupMembers(group['_id']);
        print('👥 Grupo ${group['name']}: ${members.length} miembros');
        for (final member in members) {
          occupiedStudents.add(member['student_id']);
          print('🚫 Estudiante ocupado: ${member['student_id']}');
        }
      }

      // Filtrar estudiantes disponibles
      final availableStudents = courseStudents
          .where((student) {
            final isAvailable = !occupiedStudents.contains(student['student_id']);
            print('✅ Estudiante ${student['student_id']} disponible: $isAvailable');
            return isAvailable;
          })
          .toList();

      print('✅ Estudiantes disponibles finales: ${availableStudents.length}');
      return availableStudents;
    } catch (e) {
      print('❌ Error obteniendo estudiantes disponibles: $e');
      return [];
    }
  }

  /// Métodos auxiliares privados
  
  Future<Map<String, dynamic>?> _getGroupById(String groupId) async {
    try {
      final groups = await _databaseService.read('groups');
      for (final group in groups) {
        if (group['_id'] == groupId) {
          return group;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getStudentGroupInCategory(String studentId, String categoryId) async {
    try {
      final groups = await _databaseService.read('groups');
      final categoryGroups = groups.where((g) => g['category_id'] == categoryId).toList();
      
      for (final group in categoryGroups) {
        final members = await _getGroupMembers(group['_id']);
        for (final member in members) {
          if (member['student_id'] == studentId) {
            return member;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _assignStudentsIfRandom(String categoryId, String groupId) async {
    try {
      // Obtener información de la categoría
      final categories = await _databaseService.read('categories');
      Map<String, dynamic>? category;
      for (final cat in categories) {
        if (cat['_id'] == categoryId) {
          category = cat;
          break;
        }
      }
      
      if (category == null || category['type'] != 'Aleatorio') {
        return; // Solo asignar automáticamente en categorías aleatorias
      }

      print('🎲 Asignando estudiantes automáticamente (categoría aleatoria)');
      
      // Obtener estudiantes disponibles
      final courseId = category['course_id'];
      final availableStudents = await getAvailableStudents(
        categoryId: categoryId,
        courseId: courseId,
      );

      // Obtener capacidad del grupo
      final group = await _getGroupById(groupId);
      if (group == null) return;
      
      final capacity = group['capacity'] as int;
      final studentsToAssign = availableStudents.take(capacity).toList();

      // Asignar estudiantes
      for (final student in studentsToAssign) {
        await addStudentToGroup(
          groupId: groupId,
          studentId: student['student_id'],
          categoryId: categoryId,
        );
      }

      print('✅ Asignados ${studentsToAssign.length} estudiantes automáticamente');
    } catch (e) {
      print('❌ Error asignando estudiantes automáticamente: $e');
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
