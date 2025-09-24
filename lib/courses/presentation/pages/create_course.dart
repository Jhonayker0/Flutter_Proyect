import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_course_controller.dart';

class CreateCoursePage extends GetView<CreateCourseController> {
  CreateCoursePage({super.key});
  final _formKey = GlobalKey<FormState>();

  /*Future<void> _pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.setDeadline(picked);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Cursos'),
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.add),
              text: 'Crear Curso',
            ),
            Tab(
              icon: Icon(Icons.login),
              text: 'Unirse a Curso',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildCreateCourseTab(context, cs),
          _buildJoinCourseTab(context, cs),
        ],
      ),
    );
  }

  Widget _buildCreateCourseTab(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Obx(
          () => ListView(
            children: [
              const SizedBox(height: 20),
              // Icono y título
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 48,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crear Nuevo Curso',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa la información para crear tu curso',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información sobre el límite de cursos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Límite de Cursos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Puedes crear un máximo de 3 cursos. Si necesitas más, elimina cursos antiguos primero.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: controller.nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del curso',
                  hintText: 'Escribe el nombre aquí...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (v) => controller.validateRequired(
                  v,
                  'Por favor ingresa un nombre',
                ),
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: controller.descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Escribe la descripción aquí...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (v) => controller.validateRequired(
                  v,
                  'Por favor ingresa una descripción',
                ),
              ),
              const SizedBox(height: 20),

              // Error
              if (controller.error.value != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: cs.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.error.value!,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.submit(_formKey, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crear Curso'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCourseTab(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => ListView(
          children: [
            const SizedBox(height: 20),
            // Icono y título
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.group_add,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unirse a un Curso',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa el código que te proporcionó tu profesor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Campo del código
            TextFormField(
              controller: controller.courseCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Código del curso',
                hintText: 'Pega el código aquí...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                suffixIcon: Icon(Icons.paste),
              ),
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '¿Cómo funciona?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Tu profesor te habrá enviado un código único\n'
                    '2. Pega ese código en el campo de arriba\n'
                    '3. Presiona "Unirse" para inscribirte automáticamente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Error
            if (controller.joinError.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.joinError.value!,
                        style: TextStyle(color: cs.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isJoining.value
                        ? null
                        : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isJoining.value
                        ? null
                        : controller.joinCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isJoining.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Unirse al Curso'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
