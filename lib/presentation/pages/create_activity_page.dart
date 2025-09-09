import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/create_activity_controller.dart';
import 'package:get/get.dart';

class CreateActivityPage extends GetView<CreateActivityController> {
  CreateActivityPage({super.key});

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickDeadline(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Actividad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Obx(
            () => ListView(
              children: [
                // Nombre
                TextFormField(
                  controller: controller.nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Actividad',
                    hintText: 'Escribe aquí...',
                    border: OutlineInputBorder(),
                  ),
                  validator: controller.validateName,
                ),
                const SizedBox(height: 20),

                // Descripción
                TextFormField(
                  controller: controller.descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Escribe aquí...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Fecha límite
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range),
                  title: const Text('Fecha límite'),
                  subtitle: Text(
                    controller.deadline.value != null
                        ? '${controller.deadline.value!.day}/${controller.deadline.value!.month}/${controller.deadline.value!.year}'
                        : 'Sin fecha seleccionada',
                  ),
                  trailing: TextButton(
                    onPressed: () => _pickDeadline(context),
                    child: const Text('Seleccionar'),
                  ),
                ),
                const SizedBox(height: 20),

                // Categoría
                Obx(
                  () => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedCategoryId.value,
                    items: controller.categories.map<DropdownMenuItem<int>>((
                      cat,
                    ) {
                      return DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['nombre'] as String),
                      );
                    }).toList(),
                    onChanged: controller.setCategory,
                    validator: (value) => controller.validateCategory(value),
                    hint: controller.categories.isEmpty
                        ? const Text('Cargando categorías...')
                        : const Text('Selecciona una categoría'),
                  ),
                ),
                const SizedBox(height: 30),

                // Adjuntar Archivo
                OutlinedButton.icon(
                  onPressed: () async {
                    // TODO: abrir picker y llamar controller.setAttachment(path)
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Adjuntar Archivo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: cs.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // Error
                if (controller.error.value != null)
                  Text(
                    controller.error.value!,
                    style: TextStyle(color: cs.error),
                  ),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.submit(_formKey, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear'),
                    ),
                    OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
