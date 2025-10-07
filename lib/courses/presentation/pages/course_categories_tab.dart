import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import '../../../core/services/roble_category_service.dart';
import '../../../core/services/roble_user_service.dart';
import '../../../core/services/roble_database_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CourseCategoriesTab extends GetView<CourseDetailController> {
  const CourseCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = controller.courseCategories;

        if (categories.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadRobleCategories,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Si es profesor, mostrar botón de crear categoría
                  if (controller.isProfessor) ...[
                    Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add_box, color: Colors.purple.shade700),
                        ),
                        title: const Text(
                          'Crear Primera Categoría',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        subtitle: const Text(
                          'Crear una categoría para organizar actividades y grupos',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => controller.createNewCategory(),
                      ),
                    ),
                  ],
                  // Mensaje de estado vacío
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.isProfessor 
                                ? 'Aún no has creado categorías'
                                : 'No hay categorías disponibles',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.isProfessor 
                                ? 'Crea tu primera categoría para comenzar a organizar actividades'
                                : 'Las categorías aparecerán aquí cuando estén disponibles',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRobleCategories,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length + (controller.isProfessor ? 1 : 0),
            itemBuilder: (context, index) {
              // Si es profesor, mostrar el botón de crear categoría primero
              if (controller.isProfessor && index == 0) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_box, color: Colors.purple.shade700),
                    ),
                    title: const Text(
                      'Crear Nueva Categoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    subtitle: const Text(
                      'Agregar una nueva categoría para organizar actividades',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => controller.createNewCategory(),
                  ),
                );
              }

              // Ajustar índice para las categorías
              final categoryIndex = controller.isProfessor ? index - 1 : index;
              final category = categories[categoryIndex];

              return _buildCategoryCard(category);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final name = category['name']?.toString() ?? 'Sin nombre';
    final description =
        category['description']?.toString() ?? 'Sin descripción';
    final type = category['type']?.toString() ?? 'General';
    final activityCount = category['activity_count'] as int? ?? 0;
    final groupCount = category['group_count'] as int? ?? 0;
    final totalMembers = category['total_members'] as int? ?? 0;
    final pendingActivities = category['pending_activities'] as int? ?? 0;
    final overdueActivities = category['overdue_activities'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getCategoryIcon(type), color: _getCategoryColor(type)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.assignment, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$activityCount actividades',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.group, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$groupCount grupos',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow('Pendientes', pendingActivities, Colors.orange),
                const SizedBox(height: 8),
                _buildStatsRow('Vencidas', overdueActivities, Colors.red),
                const SizedBox(height: 16),
                _buildStatsRow('Grupos', groupCount, Colors.blue),
                const SizedBox(height: 8),
                _buildStatsRow('Miembros', totalMembers, Colors.green),
                const SizedBox(height: 16),
                // Primera fila con Ver Grupos y Editar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showCategoryGroups(category),
                      icon: const Icon(Icons.group, size: 16),
                      label: const Text('Ver Grupos'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ),
                    if (controller.isProfessor)
                      ElevatedButton.icon(
                        onPressed: () => _editCategory(category),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.green.shade50,
                        ),
                      ),
                    // Espaciador si no hay botón de editar para mantener centrado Ver Grupos
                    if (!controller.isProfessor) const SizedBox(width: 120),
                  ],
                ),
                // Segunda fila con botón Eliminar (solo para profesores)
                if (controller.isProfessor) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _deleteCategory(category),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.red.shade50,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'examen':
      case 'exam':
        return Colors.red;
      case 'tarea':
      case 'homework':
        return Colors.blue;
      case 'proyecto':
      case 'project':
        return Colors.purple;
      case 'laboratorio':
      case 'lab':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'examen':
      case 'exam':
        return Icons.quiz;
      case 'tarea':
      case 'homework':
        return Icons.assignment;
      case 'proyecto':
      case 'project':
        return Icons.work;
      case 'laboratorio':
      case 'lab':
        return Icons.science;
      default:
        return Icons.category;
    }
  }

  void _showCategoryGroups(Map<String, dynamic> category) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grupos',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadCategoryGroups(category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final groups = snapshot.data ?? [];

                    if (groups.isEmpty) {
                      return const Center(
                        child: Text('No hay grupos en esta categoría'),
                      );
                    }

                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return _buildGroupCard(group, category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCategory(Map<String, dynamic> category) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 700,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestionar Grupos',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _buildGroupManagement(category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadCategoryGroups(Map<String, dynamic> category) async {
    try {
      final categoryId = category['_id'] ?? category['id'];
      if (categoryId == null) {
        print('❌ Category ID is null: $category');
        return [];
      }
      
      print('🔄 Loading groups for category ID: $categoryId');
      print('🔄 Category name: ${category['name']}');
      print('🔄 Category data: $category');
      
      final categoryService = Get.find<RobleCategoryService>();
      final groups = await categoryService.getGroupsInCategory(categoryId.toString());
      
      print('✅ Loaded ${groups.length} groups for category');
      if (groups.isNotEmpty) {
        print('📋 First group: ${groups.first}');
      }
      
      return groups;
    } catch (e) {
      print('❌ Error loading category groups: $e');
      return [];
    }
  }

  Widget _buildGroupCard(Map<String, dynamic> group, Map<String, dynamic> category) {
    final name = group['name']?.toString() ?? 'Grupo sin nombre';
    final description = group['description']?.toString() ?? 'Sin descripción';
    
    // Obtener capacidad del campo capacity de la tabla categories
    int capacity = 5; // Solo como fallback si no existe el campo
    if (category['capacity'] != null) {
      capacity = category['capacity'] as int;
    }
    
    // Debug: Verificar qué datos están llegando
    print('🔍 DEBUG _buildGroupCard:');
    print('   - Grupo: ${group['name']}');
    print('   - Category data: $category');
    print('   - Capacity field: ${category['capacity']}');
    print('   - Capacity used: $capacity');
    
    final members = group['members'] as List? ?? [];
    final memberCount = members.length;
    final capacityPercentage = capacity > 0
        ? ((memberCount / capacity) * 100).round()
        : 0;
    
    // Verificar si el usuario actual está en el grupo
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    final isUserInGroup = members.any((member) => member['student_id'] == currentUserId.toString());
    final isElectionCategory = category['type']?.toString().toLowerCase() == 'eleccion';
    final canJoin = isElectionCategory && !controller.isProfessor && !isUserInGroup && memberCount < capacity;
    final canLeave = isElectionCategory && !controller.isProfessor && isUserInGroup;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.group, color: Colors.blue.shade700, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$memberCount/$capacity miembros',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (capacity > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '($capacityPercentage%)',
                    style: TextStyle(
                      color: capacityPercentage > 80
                          ? Colors.red
                          : capacityPercentage > 60
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        children: [
          if (members.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Miembros:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...members.map((member) => _buildMemberItem(member)),
                ],
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay miembros en este grupo',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          // Botones de acción para estudiantes en categorías de elección
          if (canJoin || canLeave) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (canJoin)
                    ElevatedButton.icon(
                      onPressed: () => _joinGroup(group, category),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Inscribirse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (canLeave)
                    ElevatedButton.icon(
                      onPressed: () => _leaveGroup(group, category),
                      icon: const Icon(Icons.person_remove, size: 18),
                      label: const Text('Salirse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    final name = member['name']?.toString() ?? 'Usuario sin nombre';
    final email = member['email']?.toString() ?? '';
    final role = member['role']?.toString() ?? 'Estudiante';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: role == 'Profesor'
                ? Colors.green.shade100
                : Colors.blue.shade100,
            child: Icon(
              role == 'Profesor' ? Icons.school : Icons.person,
              size: 16,
              color: role == 'Profesor'
                  ? Colors.green.shade700
                  : Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: role == 'Profesor'
                  ? Colors.green.shade50
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: role == 'Profesor'
                    ? Colors.green.shade200
                    : Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: role == 'Profesor'
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupManagement(Map<String, dynamic> category) {
    final categoryType = category['type']?.toString() ?? '';
    final isRandom = categoryType == 'Aleatorio';
    
    return Column(
      children: [
        // Header con información de la categoría
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isRandom ? Icons.shuffle : Icons.how_to_vote,
                color: isRandom ? Colors.orange : Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo: $categoryType',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isRandom 
                        ? 'Asignación automática de estudiantes'  
                        : 'Los estudiantes pueden elegir su grupo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Botón para crear grupo
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showCreateGroupDialog(category),
              icon: const Icon(Icons.add),
              label: const Text('Crear Grupo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        
        // Lista de grupos
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadCategoryGroups(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              
              final groups = snapshot.data ?? [];
              
              if (groups.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay grupos creados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _buildGroupManagementCard(group, category);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupManagementCard(Map<String, dynamic> group, Map<String, dynamic> category) {
    final name = group['name']?.toString() ?? 'Grupo sin nombre';
    
    // Obtener capacidad del campo capacity de la tabla categories
    int capacity = 5; // Solo como fallback si no existe el campo
    if (category['capacity'] != null) {
      capacity = category['capacity'] as int;
    }
    
    // Debug: Verificar qué datos están llegando
    print('🔍 DEBUG _buildGroupManagementCard:');
    print('   - Grupo: ${group['name']}');
    print('   - Category data: $category');
    print('   - Capacity field: ${category['capacity']}');
    print('   - Capacity used: $capacity');
    
    final members = group['members'] as List? ?? [];
    final memberCount = members.length;
    final capacityPercentage = capacity > 0 ? ((memberCount / capacity) * 100).round() : 0;
    final isRandom = category['type'] == 'Aleatorio';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: capacityPercentage > 80 
            ? Colors.red.shade100 
            : capacityPercentage > 60 
              ? Colors.orange.shade100 
              : Colors.green.shade100,
          child: Icon(
            Icons.group,
            color: capacityPercentage > 80 
              ? Colors.red.shade700 
              : capacityPercentage > 60 
                ? Colors.orange.shade700 
                : Colors.green.shade700,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleGroupAction(value, group, category),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$memberCount/$capacity miembros',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (capacity > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: capacityPercentage > 80 
                        ? Colors.red.shade100 
                        : capacityPercentage > 60 
                          ? Colors.orange.shade100 
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$capacityPercentage%',
                      style: TextStyle(
                        color: capacityPercentage > 80 
                          ? Colors.red.shade700 
                          : capacityPercentage > 60 
                            ? Colors.orange.shade700 
                            : Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Miembros:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (!isRandom && memberCount < capacity)
                      ElevatedButton.icon(
                        onPressed: () => _showAddStudentDialog(group, category),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Añadir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (members.isNotEmpty) ...[
                  ...members.map((member) => _buildMemberManagementItem(member, group, category)),
                ] else ...[
                  const Text(
                    'No hay miembros en este grupo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberManagementItem(Map<String, dynamic> member, Map<String, dynamic> group, Map<String, dynamic> category) {
    final name = member['name']?.toString() ?? 'Usuario sin nombre';
    final email = member['email']?.toString() ?? '';
    final role = member['role']?.toString() ?? 'Estudiante';
    final isRandom = category['type'] == 'Aleatorio';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: role == 'Profesor' ? Colors.green.shade100 : Colors.blue.shade100,
            child: Icon(
              role == 'Profesor' ? Icons.school : Icons.person,
              size: 16,
              color: role == 'Profesor' ? Colors.green.shade700 : Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: role == 'Profesor' ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: role == 'Profesor' ? Colors.green.shade200 : Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: role == 'Profesor' ? Colors.green.shade700 : Colors.blue.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isRandom && role == 'Estudiante') ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeStudentFromGroup(member, category),
              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
              tooltip: 'Remover del grupo',
            ),
          ],
        ],
      ),
    );
  }

  void _handleGroupAction(String action, Map<String, dynamic> group, Map<String, dynamic> category) {
    switch (action) {
      case 'edit':
        _showEditGroupDialog(group, category);
        break;
      case 'delete':
        _showDeleteGroupConfirmation(group, category);
        break;
    }
  }

  void _showCreateGroupDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear Nuevo Grupo'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad máxima',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || 
                  capacityController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'El nombre y la capacidad son obligatorios',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final capacity = int.tryParse(capacityController.text.trim());
              if (capacity == null || capacity <= 0) {
                Get.snackbar(
                  'Error',
                  'La capacidad debe ser un número mayor a 0',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              await _createGroup(
                category: category,
                name: nameController.text.trim(),
                capacity: capacity,
                description: descriptionController.text.trim(),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(Map<String, dynamic> group, Map<String, dynamic> category) {
    final nameController = TextEditingController(text: group['name']?.toString() ?? '');
    final descriptionController = TextEditingController(text: group['description']?.toString() ?? '');
    
    // Obtener capacidad del campo capacity de la tabla categories
    int categoryCapacity = 5; // Solo como fallback si no existe el campo
    if (category['capacity'] != null) {
      categoryCapacity = category['capacity'] as int;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Grupo'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Capacidad máxima: $categoryCapacity estudiantes (definida por la categoría)',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'El nombre es obligatorio',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              await _updateGroup(
                group: group,
                category: category,
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupConfirmation(Map<String, dynamic> group, Map<String, dynamic> category) {
    final name = group['name']?.toString() ?? 'Grupo';
    final memberCount = (group['members'] as List?)?.length ?? 0;

    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que deseas eliminar el grupo "$name"?'),
            if (memberCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Advertencia: Este grupo tiene $memberCount miembro(s) que serán removidos.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteGroup(group, category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(Map<String, dynamic> group, Map<String, dynamic> category) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Añadir Estudiante',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadAvailableStudents(category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    
                    final students = snapshot.data ?? [];
                    
                    if (students.isEmpty) {
                      return const Center(
                        child: Text('No hay estudiantes disponibles'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildAvailableStudentItem(student, group, category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableStudentItem(Map<String, dynamic> student, Map<String, dynamic> group, Map<String, dynamic> category) {
    final name = student['name']?.toString() ?? 'Usuario sin nombre';
    final email = student['email']?.toString() ?? student['student_id']?.toString() ?? '';
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(
          Icons.person,
          color: Colors.blue.shade700,
          size: 20,
        ),
      ),
      title: Text(name),
      subtitle: Text(email),
      trailing: ElevatedButton(
        onPressed: () => _addStudentToGroup(student, group, category),
        child: const Text('Añadir'),
      ),
    );
  }

  // Métodos de acción
  Future<void> _createGroup({
    required Map<String, dynamic> category,
    required String name,
    required int capacity,
    required String description,
  }) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      
      final result = await categoryService.createGroup(
        categoryId: category['_id'],
        name: name,
        capacity: capacity,
        description: description.isEmpty ? null : description,
      );
      
      if (result != null) {
        Get.back(); // Cerrar diálogo
        Get.snackbar(
          'Éxito',
          'Grupo creado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista
        controller.loadRobleCategories();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo crear el grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al crear el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateGroup({
    required Map<String, dynamic> group,
    required Map<String, dynamic> category,
    required String name,
    required String description,
  }) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.updateGroup(
        groupId: group['_id'],
        name: name,
        capacity: null, // La capacidad ya no se actualiza en grupos
        description: description.isEmpty ? null : description,
      );
      
      if (success) {
        Get.back(); // Cerrar diálogo
        Get.snackbar(
          'Éxito',
          'Grupo actualizado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista
        controller.loadRobleCategories();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo actualizar el grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteGroup(Map<String, dynamic> group, Map<String, dynamic> category) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.deleteGroup(group['_id']);
      
      if (success) {
        Get.back(); // Cerrar diálogo de confirmación
        Get.back(); // Cerrar diálogo de gestión si está abierto
        Get.snackbar(
          'Éxito',
          'Grupo eliminado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista
        controller.loadRobleCategories();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo eliminar el grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _addStudentToGroup(Map<String, dynamic> student, Map<String, dynamic> group, Map<String, dynamic> category) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.addStudentToGroup(
        groupId: group['_id'],
        studentId: student['student_id'],
        categoryId: category['_id'],
      );
      
      if (success) {
        Get.back(); // Cerrar diálogo de añadir estudiante
        Get.snackbar(
          'Éxito',
          'Estudiante añadido al grupo',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista
        controller.loadRobleCategories();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo añadir el estudiante al grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al añadir estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _removeStudentFromGroup(Map<String, dynamic> member, Map<String, dynamic> category) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.removeStudentFromGroup(
        studentId: member['student_id'],
        categoryId: category['_id'],
      );
      
      if (success) {
        Get.snackbar(
          'Éxito',
          'Estudiante removido del grupo',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista
        controller.loadRobleCategories();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo remover el estudiante del grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al remover estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadAvailableStudents(Map<String, dynamic> category) async {
    try {
      final categoryService = Get.find<RobleCategoryService>();
      final courseId = controller.course.id ?? '';
      
      final availableStudents = await categoryService.getAvailableStudents(
        categoryId: category['_id'],
        courseId: courseId,
      );
      
      // Obtener nombres reales de los estudiantes usando el servicio de usuarios
      final userService = Get.find<RobleUserService>();
      final processedStudents = <Map<String, dynamic>>[];
      
      for (final student in availableStudents) {
        final studentId = student['student_id'];
        final userInfo = await userService.getUserInfo(studentId);
        
        processedStudents.add({
          ...student,
          'name': userInfo['name'] ?? 'Usuario sin nombre',
          'email': userInfo['email'] ?? studentId,
        });
      }
      
      return processedStudents;
    } catch (e) {
      print('❌ Error loading available students: $e');
      return [];
    }
  }

  Future<void> _joinGroup(Map<String, dynamic> group, Map<String, dynamic> category) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.id;
      
      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'No se pudo obtener la información del usuario',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.addStudentToGroup(
        groupId: group['_id'],
        studentId: currentUserId.toString(),
        categoryId: category['_id'],
      );
      
      if (success) {
        Get.snackbar(
          'Éxito',
          'Te has inscrito exitosamente en el grupo',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista de categorías
        controller.loadRobleCategories();
        
        // Cerrar el diálogo actual y volver a abrirlo para mostrar los cambios
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        _showCategoryGroups(category);
      } else {
        Get.snackbar(
          'Error',
          'No se pudo inscribir en el grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al inscribirse en el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _leaveGroup(Map<String, dynamic> group, Map<String, dynamic> category) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser.value?.id;
      
      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'No se pudo obtener la información del usuario',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Mostrar confirmación
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar salida'),
          content: Text('¿Estás seguro de que deseas salirte del grupo "${group['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salir'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final categoryService = Get.find<RobleCategoryService>();
      
      final success = await categoryService.removeStudentFromGroup(
        studentId: currentUserId.toString(),
        categoryId: category['_id'],
      );
      
      if (success) {
        Get.snackbar(
          'Éxito',
          'Te has salido exitosamente del grupo',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Recargar la vista de categorías
        controller.loadRobleCategories();
        
        // Cerrar el diálogo actual y volver a abrirlo para mostrar los cambios
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        _showCategoryGroups(category);
      } else {
        Get.snackbar(
          'Error',
          'No se pudo salir del grupo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al salirse del grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Eliminar categoría (solo para profesores)
  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final categoryName = category['name']?.toString() ?? 'Sin nombre';
    
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
            const Text('Eliminar Categoría'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar la categoría "$categoryName"?',
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
                        'Esta acción eliminará:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Todos los grupos de esta categoría\n'
                    '• Todas las actividades asociadas\n'
                    '• Los miembros de los grupos\n'
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
            child: const Text('Eliminar Categoría'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await _performDeleteCategory(category);
    }
  }

  /// Ejecutar la eliminación de la categoría
  Future<void> _performDeleteCategory(Map<String, dynamic> category) async {
    try {
      // Obtener servicios necesarios
      final databaseService = Get.find<RobleDatabaseService>();
      final categoryId = category['_id']?.toString();
      
      if (categoryId == null) {
        throw Exception('ID de categoría no encontrado');
      }

      print('🗑️ Eliminando categoría: $categoryId');

      // Primero eliminar todas las actividades de la categoría
      final activities = await databaseService.read('activities');
      final categoryActivities = activities
          .where((activity) => activity['category_id'] == categoryId)
          .toList();
      
      for (final activity in categoryActivities) {
        await databaseService.delete('activities', activity['_id']);
        print('🗑️ Actividad eliminada: ${activity['_id']}');
      }

      // Luego eliminar todos los grupos de la categoría
      final groups = await databaseService.read('groups');
      final categoryGroups = groups
          .where((group) => group['category_id'] == categoryId)
          .toList();
      
      for (final group in categoryGroups) {
        // Eliminar miembros del grupo
        final members = await databaseService.read('group_members');
        final groupMembers = members
            .where((member) => member['group_id'] == group['_id'])
            .toList();
        
        for (final member in groupMembers) {
          await databaseService.delete('group_members', member['_id']);
          print('🗑️ Miembro eliminado: ${member['_id']}');
        }
        
        // Eliminar el grupo
        await databaseService.delete('groups', group['_id']);
        print('🗑️ Grupo eliminado: ${group['_id']}');
      }

      // Finalmente eliminar la categoría
      await databaseService.delete('categories', categoryId);
      print('✅ Categoría eliminada: $categoryId');

      Get.snackbar(
        'Éxito',
        'La categoría "${category['name']}" ha sido eliminada correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Recargar la vista de categorías
      controller.loadRobleCategories();

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la categoría: $e',
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error deleting category: $e');
    }
  }
}
