import 'package:flutter/material.dart';
import 'package:flutter_application/activities/presentation/controllers/create_activity_controller.dart';
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
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Cargando categorías...'),
                          ],
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedCategoryId.value,
                    items: controller.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['_id']?.toString(),
                        child: Text(category['name']?.toString() ?? 'Sin nombre'),
                      );
                    }).toList(),
                    onChanged: controller.setCategory,
                    validator: controller.validateCategory,
                    hint: const Text('Selecciona una categoría'),
                  );
                }),
                const SizedBox(height: 30),

                // Error
                Obx(() => controller.error.value != null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cs.error.withOpacity(0.1),
                        border: Border.all(color: cs.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.error.value!,
                        style: TextStyle(color: cs.error),
                      ),
                    )
                  : const SizedBox.shrink()),

                // Botones
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              print('🎯 Botón Crear presionado');
                              controller.submit(_formKey, context);
                            },
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
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
