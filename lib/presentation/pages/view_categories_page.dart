// presentation/pages/category_groups_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

class CategoryGroupsPage extends GetView<CategoryGroupsController> {
  const CategoryGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías y Grupos'), automaticallyImplyLeading: false),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final cats = controller.categories;
        if (cats.isEmpty) {
          return const Center(child: Text('No hay categorías'));
        }
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cats.length,
            itemBuilder: (_, index) {
              final cat = cats[index];
              final groups = controller.groupsByCat[cat.id];
              final loading = controller.loadingCat.contains(cat.id);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              final ok = await Get.toNamed(('/edit-category/${cat.id}'),
                              );
                              if (ok == true) {
                                await controller.refreshAll();
                              }
                              break;
                            case 'delete':
                              final confirm = await _confirmDeleteCategory(context, cat.name);
                              if (confirm == true) {
                                await controller.deleteCategory(cat.id);
                                await controller.refreshAll();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Editar categoría'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Eliminar categoría'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text('Tipo: ${cat.type} • Capacidad: ${cat.capacity ?? '-'}'),
                  onExpansionChanged: (expanded) {
                    if (expanded) controller.loadGroupsFor(cat.id);
                  },
                  children: [
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (groups == null || groups.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Sin grupos creados'),
                      )
                    else
                      ...groups.map(
                        (g) => ListTile(
                          leading: const Icon(Icons.groups),
                          title: Text(g.name),
                          subtitle: Text('Miembros: ${g.members} • Capacidad: ${g.capacity ?? '-'}'),
                          onTap: () => _showGroupMembersDialog(context, g.id, g.name, cat.id),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }


  void _showGroupMembersDialog(BuildContext context, int groupId, String groupName, int categoriaId) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Miembros de $groupName'),
          content: FutureBuilder<List<MemberVM>>(
            future: controller.getMembersByGroup(groupId, categoriaId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return SizedBox(
                  height: 120,
                  child: Center(child: Text('Error: ${snap.error}')),
                );
              }
              final members = snap.data ?? const <MemberVM>[];
              if (members.isEmpty) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: Text('Sin miembros')),
                );
              }
              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(m.name),
                      subtitle: m.email != null ? Text(m.email!) : null,
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }


  Future<bool?> _confirmDeleteCategory(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar la categoría "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}
