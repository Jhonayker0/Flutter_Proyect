import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';

class CourseInfoTab extends GetView<CourseDetailController> {
  const CourseInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica del curso
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Información del Curso',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', controller.course.title),
                    _buildInfoRow('Descripción', controller.course.description),
                    _buildInfoRow('Tu rol', controller.course.role),
                    Obx(
                      () => _buildInfoRow(
                        'Total de estudiantes',
                        '${controller.studentCount.value}',
                      ),
                    ),
                    _buildInfoRow(
                      'Fecha de creación',
                      _formatDate(controller.course.createdAt),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Estadísticas del curso
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Column(
                        children: [
                          _buildStatRow(
                            'Total de actividades',
                            '${controller.activities.length}',
                            Icons.assignment,
                            Colors.blue,
                          ),
                          _buildStatRow(
                            'Estudiantes inscritos',
                            '${controller.studentCount.value}',
                            Icons.people,
                            Colors.green,
                          ),
                          if (!controller.isProfessor) ...[
                            _buildStatRow(
                              'Actividades completadas',
                              '${controller.activities.where((a) => a.isCompleted).length}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatRow(
                              'Actividades pendientes',
                              '${controller.activities.where((a) => !a.isCompleted).length}',
                              Icons.pending,
                              Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Acciones rápidas
            if (controller.isProfessor)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.purple.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Acciones Rápidas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        'Crear Nueva Actividad',
                        'Agregar tarea, examen o proyecto',
                        Icons.add_circle,
                        Colors.green,
                        controller.createNewActivity,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        'Invitar Estudiante',
                        'Enviar invitación para unirse al curso',
                        Icons.person_add,
                        Colors.blue,
                        controller.inviteStudent,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        'Crear categoria',
                        'Crea una nueva categoria para el curso',
                        Icons.add_circle,
                        Colors.orange,
                        controller.createNewCategory,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
