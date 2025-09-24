import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';


class CourseActivitiesTab extends GetView<CourseDetailController> {
  const CourseActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoadingActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = controller.courseActivities;

        if (activities.isEmpty && !controller.isProfessor) {
          return RefreshIndicator(
            onRefresh: controller.loadRobleActivities,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay actividades disponibles',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Las actividades aparecerán aquí cuando estén disponibles',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRobleActivities,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length + (controller.isProfessor ? 1 : 0),
            itemBuilder: (context, index) {
              // Si es profesor, mostrar el botón de crear actividad primero
              if (controller.isProfessor && index == 0) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: Colors.green.shade700),
                    ),
                    title: const Text(
                      'Crear Nueva Actividad',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: const Text(
                      'Agregar una nueva tarea, examen o proyecto',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.createNewActivity,
                  ),
                );
              }

              // Ajustar índice para las actividades
              final activityIndex = controller.isProfessor ? index - 1 : index;
              final activity = activities[activityIndex];

              return _buildRobleActivityCard(activity);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRobleActivityCard(Map<String, dynamic> activity) {
    final title = activity['title']?.toString() ?? 'Sin título';
    final description =
        activity['description']?.toString() ?? 'Sin descripción';
    final type = activity['type']?.toString() ?? 'Actividad';
    final formattedDate =
        activity['formatted_due_date']?.toString() ?? 'Sin fecha';
    final categoryName = activity['category_name']?.toString();
    final isOverdue = activity['is_overdue'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActivityColorFromType(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getActivityIconFromType(type),
            color: _getActivityColorFromType(type),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey.shade600, 
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (categoryName != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    categoryName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información detallada
                _buildDetailRow('Descripción completa', description),
                const SizedBox(height: 8),
                _buildDetailRow('Tipo de actividad', type),
                const SizedBox(height: 8),
                _buildDetailRow('Fecha límite', formattedDate),
                if (categoryName != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Categoría', categoryName),
                ],
                if (isOverdue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '⚠️ Actividad vencida',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Botones según el rol del usuario
                if (controller.isProfessor) ...[
                  // Vista del profesor: Ver notas y Borrar actividad
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('📊 Ver notas - Actividad: $title');
                        // TODO: Navegar a página de ver notas
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.grade),
                      label: const Text('Ver notas'),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print('🗑️ Borrar actividad - Actividad: $title');
                        await controller.deleteActivity(activity);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Borrar actividad'),
                    ),
                  ),
                ] else ...[
                  // Vista del estudiante: Evaluar compañeros y Responder actividad
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('🔍 Evaluar a mis compañeros - Actividad: $title');
                        // TODO: Navegar a página de evaluación
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.people_alt),
                      label: const Text('Evaluar a mis compañeros'),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print('📝 Responder actividad - Actividad: $title');
                        await controller.showResponseDialog(activity);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Responder actividad'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }



  // Método temporalmente deshabilitado
  // TODO: Implementar cuando sea necesario
  /*
  Widget _buildActivityCard(Activity activity) {
    // Implementación del método aquí
  }
  */

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'tarea':
        return Colors.blue;
      case 'examen':
        return Colors.red;
      case 'proyecto':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tarea':
        return Icons.assignment;
      case 'examen':
        return Icons.quiz;
      case 'proyecto':
        return Icons.work;
      default:
        return Icons.description;
    }
  }

  // String _formatDate(DateTime date) {
  //   final now = DateTime.now();
  //   final difference = date.difference(now).inDays;

  //   if (difference < 0) {
  //     return 'Vencido';
  //   } else if (difference == 0) {
  //     return 'Hoy';
  //   } else if (difference == 1) {
  //     return 'Mañana';
  //   } else {
  //     return '${date.day}/${date.month}/${date.year}';
  //   }
  // }

  // Métodos para el nuevo formato de ROBLE
  Color _getActivityColorFromType(String type) {
    return _getActivityColor(type);
  }

  IconData _getActivityIconFromType(String type) {
    return _getActivityIcon(type);
  }
}
