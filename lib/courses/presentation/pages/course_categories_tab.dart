import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import '../../../core/services/roble_category_service.dart';

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
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay categorías disponibles',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Las categorías aparecerán aquí cuando estén disponibles',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
                    onTap: () => _showCreateCategoryDialog(),
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
                  ],
                ),
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
                    'Grupos - ${category['name']}',
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
                        return _buildGroupCard(group);
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
    // Implementar edición de categoría
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Editar ${category['name']}'),
        content: const Text('Funcionalidad para editar esta categoría'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Categoría'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Crear'),
          ),
        ],
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

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final name = group['name']?.toString() ?? 'Grupo sin nombre';
    final description = group['description']?.toString() ?? 'Sin descripción';
    final capacity = group['capacity'] as int? ?? 0;
    final members = group['members'] as List? ?? [];
    final memberCount = members.length;
    final capacityPercentage = capacity > 0
        ? ((memberCount / capacity) * 100).round()
        : 0;

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
}
