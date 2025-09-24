import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/view_categories_controller.dart';

class CategoriesPage extends GetView<CategoryGroupsController> {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías y Grupos'),
        actions: [
          // Debug: Siempre mostrar los botones para probar
          IconButton(
            onPressed: () {
              _showManageStudentsDialog();
            },
            icon: const Icon(Icons.people),
            tooltip: 'Gestionar estudiantes',
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(
                '/create-category',
                arguments: {'courseId': controller.courseId},
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Crear categoría',
          ),
          // Mostrar rol actual para debug
          IconButton(
            onPressed: () {
              Get.snackbar('Debug', 'Rol actual: ${controller.role}');
            },
            icon: const Icon(Icons.info),
            tooltip: 'Ver rol',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshAll,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay categorías',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (controller.role == 'profesor') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(
                        '/create-category',
                        arguments: {'courseId': controller.courseId},
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera categoría'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _buildCategoryCard(context, category);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryVM category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.category, color: Colors.white),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    category.type,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: category.type == 'auto-asignado'
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
                const SizedBox(width: 8),
                Text(
                  'Descripción: ${category.description}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Get.toNamed('/edit-category/${category.id}');
            } else if (value == 'delete') {
              _confirmDelete(category);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            controller.loadGroupsFor(category.id);
          }
        },
        children: [_buildGroupsList(category)],
      ),
    );
  }

  Widget _buildGroupsList(CategoryVM category) {
    return Obx(() {
      if (controller.loadingCat.contains(category.id)) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final groups = controller.groupsByCat[category.id] ?? [];

      if (groups.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay grupos en esta categoría',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Column(
        children: groups
            .map((group) => _buildGroupTile(group, category.id))
            .toList(),
      );
    });
  }

  Widget _buildGroupTile(GroupVM group, String categoryId) {
    return Obx(() {
      final userGroupId = controller.userGroupByCategory[categoryId];
      final isUserInThisGroup = userGroupId == group.id;

      return ListTile(
        leading: CircleAvatar(
          backgroundColor: isUserInThisGroup
              ? Colors.green
              : Colors.grey.shade300,
          child: Icon(
            Icons.group,
            color: isUserInThisGroup ? Colors.white : Colors.grey.shade600,
          ),
        ),
        title: Text(group.name),
        subtitle: Text(
          '${group.members} miembros${group.capacity != null ? ' / ${group.capacity}' : ''}',
        ),
        trailing: controller.role == 'estudiante' && !isUserInThisGroup
            ? ElevatedButton(
                onPressed: () => controller.joinGroup(group.id),
                child: const Text('Unirse'),
              )
            : isUserInThisGroup
            ? const Chip(
                label: Text('Mi grupo'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            : null,
        onTap: () => _showGroupMembers(group, categoryId),
      );
    });
  }

  Future<void> _showGroupMembers(GroupVM group, String categoryId) async {
    try {
      final members = await controller.getMembersByGroup(group.id, categoryId);

      Get.dialog(
        AlertDialog(
          title: Text('Miembros de ${group.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: members.isEmpty
                ? const Text('No hay miembros en este grupo')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(member.name[0].toUpperCase()),
                        ),
                        title: Text(member.name),
                        subtitle: member.email != null
                            ? Text(member.email!)
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los miembros: $e');
    }
  }

  Future<void> _confirmDelete(CategoryVM category) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.deleteCategory(category.id);
        controller.refreshAll();
      } catch (e) {
        // El error ya se maneja en el controlador
      }
    }
  }

  void _showManageStudentsDialog() {
    if (controller.categories.isEmpty) {
      Get.snackbar('Info', 'Primero debes crear al menos una categoría');
      return;
    }

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Gestionar Estudiantes en Grupos',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(category.name),
                        subtitle: Text('Tipo: ${category.type}'),
                        children: [
                          FutureBuilder<List<MemberVM>>(
                            future: controller.getUnassignedStudents(
                              category.id,
                            ),
                            builder: (context, snapshot) {
                              final unassigned = snapshot.data ?? [];
                              final groups =
                                  controller.groupsByCat[category.id] ?? [];

                              return Column(
                                children: [
                                  if (unassigned.isNotEmpty) ...[
                                    const ListTile(
                                      title: Text('Estudiantes sin asignar:'),
                                      dense: true,
                                    ),
                                    ...unassigned.map(
                                      (student) => ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            student.name[0].toUpperCase(),
                                          ),
                                        ),
                                        title: Text(student.name),
                                        subtitle: student.email != null
                                            ? Text(student.email!)
                                            : null,
                                        trailing: groups.isNotEmpty
                                            ? PopupMenuButton<int>(
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Colors.green,
                                                ),
                                                tooltip: 'Asignar a grupo',
                                                onSelected: (groupId) {
                                                  controller
                                                      .assignStudentToGroup(
                                                        student.id,
                                                        groupId,
                                                        category.id,
                                                      );
                                                },
                                                itemBuilder: (context) => groups
                                                    .map(
                                                      (group) => PopupMenuItem(
                                                        value: group.id,
                                                        child: Text(
                                                          'Asignar a ${group.name}',
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                  if (groups.isNotEmpty) ...[
                                    const Divider(),
                                    const ListTile(
                                      title: Text('Grupos existentes:'),
                                      dense: true,
                                    ),
                                    ...groups.map(
                                      (group) => ExpansionTile(
                                        title: Text(group.name),
                                        subtitle: Text(
                                          '${group.members} miembros',
                                        ),
                                        children: [
                                          FutureBuilder<List<MemberVM>>(
                                            future: controller
                                                .getMembersByGroup(
                                                  group.id,
                                                  category.id,
                                                ),
                                            builder: (context, memberSnapshot) {
                                              final members =
                                                  memberSnapshot.data ?? [];
                                              if (members.isEmpty) {
                                                return const ListTile(
                                                  title: Text('Sin miembros'),
                                                  dense: true,
                                                );
                                              }
                                              return Column(
                                                children: members
                                                    .map(
                                                      (member) => ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .blue
                                                                  .shade100,
                                                          child: Text(
                                                            member.name[0]
                                                                .toUpperCase(),
                                                          ),
                                                        ),
                                                        title: Text(
                                                          member.name,
                                                        ),
                                                        subtitle:
                                                            member.email != null
                                                            ? Text(
                                                                member.email!,
                                                              )
                                                            : null,
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                            Icons.remove_circle,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            controller
                                                                .removeStudentFromGroup(
                                                                  member.id,
                                                                  category.id,
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (unassigned.isEmpty && groups.isEmpty)
                                    const ListTile(
                                      title: Text(
                                        'No hay grupos en esta categoría',
                                      ),
                                      dense: true,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
