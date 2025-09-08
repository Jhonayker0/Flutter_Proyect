import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller_new.dart';

class CoursesPage extends GetView<HomeController> {
  const CoursesPage({super.key});

  Future<void> _showSortOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[
              ('Nombre A-Z', SortOption.nameAsc),
              ('Nombre Z-A', SortOption.nameDesc),
              ('Más recientes', SortOption.dateDesc),
              ('Más antiguos', SortOption.dateAsc),
              ('Más estudiantes', SortOption.studentsDesc),
              ('Menos estudiantes', SortOption.studentsAsc),
            ].map((option) => ListTile(
                  title: Text(option.$1),
                  trailing: Obx(() => controller.currentSort.value == option.$2
                      ? const Icon(Icons.check, color: Colors.blue)
                      : const SizedBox()),
                  onTap: () {
                    controller.setSortOption(option.$2);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Rol',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Profesor'),
              trailing: Obx(() => controller.activeRoleFilter.value ==
                      HomeController.roleProfessor
                  ? const Icon(Icons.check, color: Colors.blue)
                  : const SizedBox()),
              onTap: () {
                controller.setRoleFilter(HomeController.roleProfessor);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Estudiante'),
              trailing: Obx(() => controller.activeRoleFilter.value ==
                      HomeController.roleStudent
                  ? const Icon(Icons.check, color: Colors.blue)
                  : const SizedBox()),
              onTap: () {
                controller.setRoleFilter(HomeController.roleStudent);
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Limpiar filtro'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: "Buscar cursos...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showSortOptions(context),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, size: 20),
                      const SizedBox(width: 4),
                      Obx(() => Text(controller.sortLabel)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showFilterOptions(context),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 20),
                      const SizedBox(width: 4),
                      const Text('Filtrar'),
                      const SizedBox(width: 8),
                      Obx(() => controller.activeFilters.value > 0
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${controller.activeFilters.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tus cursos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final courses = controller.courses;
                if (courses.isEmpty) {
                  return const Center(child: Text('No se encontraron cursos'));
                }
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/course-detail',
                            arguments: {'course': course});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                color: Colors.blue.shade300,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rol: ${course.role}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Estudiantes: ${course.students}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
