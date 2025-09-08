import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller_new.dart';

class CoursesPage extends GetView<HomeController> {
  const CoursesPage({super.key});

  // Mostrar opciones de ordenamiento
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
              'Sort by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[
              ('Name A-Z', SortOption.nameAsc),
              ('Name Z-A', SortOption.nameDesc),
              ('Newest First', SortOption.dateDesc),
              ('Oldest First', SortOption.dateAsc),
             // ('More Students', SortOption.studentsDesc),
              //('Less Students', SortOption.studentsAsc),
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

  // Mostrar opciones de filtro
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
              'Filter by Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Professor'),
              trailing: Obx(() => controller.activeRoleFilter.value == HomeController.roleProfessor
                  ? const Icon(Icons.check, color: Colors.blue)
                  : const SizedBox()),
              onTap: () {
                controller.setRoleFilter(HomeController.roleProfessor);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Student'),
              trailing: Obx(() => controller.activeRoleFilter.value == HomeController.roleStudent
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
              title: const Text('Clear Filter'),
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
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Campo de búsqueda
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: "Search courses...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Barra de ordenar y filtrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Sort
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
                
                // Botón Filter
                GestureDetector(
                  onTap: () => _showFilterOptions(context),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 20),
                      const SizedBox(width: 4),
                      const Text('Filter'),
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
            
            // Título de sección
            const Text(
              'Your courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de cursos
            Expanded(
              child: controller.courses.isEmpty
                  ? const Center(child: Text('No courses found'))
                  : ListView.builder(
                      itemCount: controller.courses.length,
                      itemBuilder: (context, index) {
                        final course = controller.courses[index];
                        return Container(
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
                              // Imagen del curso
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
                              
                              // Información del curso
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
                                      'Role: ${course.role}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      'Students: 0',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Flecha
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        )),
      ),
    );
  }
}
