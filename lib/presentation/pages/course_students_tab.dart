import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import '../../domain/models/student.dart';

class CourseStudentsTab extends GetView<CourseDetailController> {
  const CourseStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = controller.students;
        
        return RefreshIndicator(
          onRefresh: controller.loadStudents,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length + (controller.isProfessor ? 1 : 0),
            itemBuilder: (context, index) {
              // Si es profesor, mostrar el botón de invitar estudiante primero
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

              // Ajustar índice para los estudiantes
              final studentIndex = controller.isProfessor ? index - 1 : index;
              final student = students[studentIndex];

              return _buildStudentCard(student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: student.profileImage != null 
              ? NetworkImage(student.profileImage!)
              : null,
          child: student.profileImage == null
              ? Text(
                  student.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                )
              : null,
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso: ${student.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      LinearProgressIndicator(
                        value: student.progressPercentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(student.progressPercentage),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (student.averageGrade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGradeColor(student.averageGrade!).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.averageGrade!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getGradeColor(student.averageGrade!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Actividades: ${student.completedActivities}/${student.totalActivities}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
        onTap: () => controller.viewStudent(student),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    return Colors.red;
  }
}
