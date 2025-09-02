import 'package:flutter/material.dart';
import 'package:flutter_application/routes.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  Future<void> _openRoleFilter(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Profesor'),
              onTap: () {
                controller.setRoleFilter(HomeController.roleProfessor);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Estudiante'),
              onTap: () {
                controller.setRoleFilter(HomeController.roleStudent);
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            if (controller.activeRoleFilter.value != null)
              ListTile(
                leading: Icon(Icons.filter_alt_off, color: cs.error),
                title: Text('Borrar filtro', style: TextStyle(color: cs.error)),
                onTap: () {
                  controller.clearRoleFilter();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Main Page"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == "logout") {
                Get.offAllNamed('/login'); // limpia la pila y va a login
              } else if (value == "perfil") {
                Get.toNamed('/settings');
              } else {
                Get.snackbar("Info", "Opción no implementada");
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "perfil", child: Text("Perfil")),
              PopupMenuItem(value: "notificaciones", child: Text("Notificaciones")),
              PopupMenuItem(value: "logout", child: Text("Cerrar sesión")),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      return Text(
                        controller.currentUserName.value,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: controller.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: "Search courses...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openRoleFilter(context),
                      icon: const Icon(Icons.filter_list),
                      label: const Text("Filtrar"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                if (controller.activeRoleFilter.value != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text('Filtro: ${controller.activeRoleFilterLabel}'),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: controller.clearRoleFilter,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),
                const Text(
                  "Your courses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: controller.courses.isEmpty
                      ? const Center(child: Text('Sin resultados'))
                      : ListView.builder(
                          itemCount: controller.courses.length,
                          itemBuilder: (context, index) {
                            final c = controller.courses[index];
                            return CourseCard(title: c.title, role: c.role);
                          },
                        ),
                ),
              ],
            )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
         Get.toNamed(Routes.createCourse);
        },
        label: const Text("Crear curso"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String role;
  const CourseCard({super.key, required this.title, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: const Icon(Icons.book, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Role: $role"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {},
      ),
    );
  }
}
