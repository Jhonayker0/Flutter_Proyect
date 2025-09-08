// presentation/pages/category_groups_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

class CategoryGroupsPage extends GetView<CategoryGroupsController> {
  const CategoryGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías y Grupos'),automaticallyImplyLeading: false),
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
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      ...groups.map((g) => ListTile(
                            leading: const Icon(Icons.groups),
                            title: Text(g.name),
                            subtitle: Text('Miembros: ${g.members} • Capacidad: ${g.capacity ?? '-'}'),
                          )),
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
}
