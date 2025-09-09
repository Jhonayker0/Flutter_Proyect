import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

// Asumo que usas los mismos ViewModels y Controller pero adaptados para estudiantes
class StudentGroupsPage extends GetView<CategoryGroupsController> {
  const StudentGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos y Grupos'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final cats = controller.categories;
        if (cats.isEmpty) {
          return const Center(child: Text('No hay categorías disponibles'));
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
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
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
                          trailing: _buildJoinButton(context, g, cat.id),
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

  /// Botón o mensaje según estado del usuario
  Widget _buildJoinButton(BuildContext context, GroupVM g, int categoriaId) {
    final isFull = g.capacity != null && g.members >= g.capacity!;
    final userGroupId = controller.userGroupByCategory[categoriaId];

    final yaEnEsteGrupo = userGroupId == g.id;
    final yaEnOtroGrupo = userGroupId != null && userGroupId != g.id;

    if (yaEnEsteGrupo) {
      return const Text("Ya estás en este grupo",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    }

    if (yaEnOtroGrupo) {
      return const Text("Ya estás en un grupo",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    }

    return ElevatedButton(
      onPressed: isFull
          ? null
          : () async {
              final confirm = await _confirmJoinGroup(context, g.name);
              if (confirm == true) {
                await controller.joinGroup(g.id);
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(isFull ? 'Lleno' : 'Inscribirse'),
    );
  }

  /// Muestra los miembros de un grupo
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

  /// Confirmar inscripción
  Future<bool?> _confirmJoinGroup(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inscribirse en grupo'),
        content: Text('¿Quieres inscribirte en el grupo "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Inscribirse')),
        ],
      ),
    );
  }
}
