import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import '../../domain/models/user.dart';

class CourseStudentsTab extends GetView<CourseDetailController> {
  const CourseStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = controller.students;

        return RefreshIndicator(
          onRefresh: controller.loadStudents,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length + (controller.isProfessor ? 1 : 0),
            itemBuilder: (context, index) {
              // Si es profesor, mostrar el botón de invitar usuario primero
              if (controller.isProfessor && index == 0) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: const Text(
                      'Invitar Nuevo Estudiante',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: const Text('Enviar invitación para unirse al curso'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.inviteStudent,
                  ),
                );
              }

              // Ajustar índice para los usuarios
              final userIndex = controller.isProfessor ? index - 1 : index;
              final user = users[userIndex];

              return _buildUserCard(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: user.imagepathh != null
              ? NetworkImage(user.imagepathh!)
              : null,
          child: user.imagepathh == null
              ? Text(
                  user.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.viewStudent(user),
      ),
    );
  }
}
