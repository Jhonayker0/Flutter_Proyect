import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import 'package:flutter_application/auth/domain/models/user.dart';

class CourseStudentsTab extends GetView<CourseDetailController> {
  const CourseStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Usar courseUsers en lugar de students para tener acceso a los roles
        final usersWithRoles = controller.courseUsers;
        final showInviteButton = controller.isProfessor;

        return RefreshIndicator(
          onRefresh: controller.loadStudents,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usersWithRoles.length + (showInviteButton ? 1 : 0),
            itemBuilder: (context, index) {
              // Si es profesor, mostrar el botón de invitar usuario primero
              if (showInviteButton && index == 0) {
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
                    subtitle: const Text(
                      'Enviar invitación para unirse al curso',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.inviteStudent,
                  ),
                );
              }

              // Ajustar índice para los usuarios
              final userIndex = showInviteButton ? index - 1 : index;
              final userWithRole = usersWithRoles[userIndex];

              return _buildUserCardWithRole(userWithRole);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserCardWithRole(Map<String, dynamic> userData) {
    final String name = userData['name'] ?? 'Usuario';
    final String email = userData['email'] ?? '';
    final String? imagePath = userData['imagepathh'];
    final String role = userData['role'] ?? 'student';

    // Configurar colores y etiquetas según el rol
    Color roleColor;
    String roleLabel;
    IconData roleIcon;

    switch (role.toLowerCase()) {
      case 'professor':
      case 'teacher':
        roleColor = Colors.purple;
        roleLabel = 'Profesor';
        roleIcon = Icons.school;
        break;
      case 'student':
      default:
        roleColor = Colors.green;
        roleLabel = 'Estudiante';
        roleIcon = Icons.person;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: imagePath != null ? NetworkImage(imagePath) : null,
          child: imagePath == null
              ? Text(
                  name
                      .split(' ')
                      .map((n) => n.isNotEmpty ? n[0] : '')
                      .take(2)
                      .join(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Etiqueta de rol como en el homepage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: roleColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleIcon, size: 14, color: roleColor),
                  const SizedBox(width: 4),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.viewStudent(
          User(
            id: userData['uuid'].hashCode.abs(),
            name: name,
            email: email,
            imagepathh: imagePath,
            uuid: userData['uuid'],
          ),
        ),
      ),
    );
  }
}
