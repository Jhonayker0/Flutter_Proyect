import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_category_controller.dart';

class EditCategoryPage extends GetView<EditCategoryController> {
  EditCategoryPage({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Categoría')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: controller.nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Categoría',
                    hintText: 'Escribe aquí...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      controller.validateRequired(v, 'Por favor ingresa un nombre'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Escribe aquí...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => controller
                      .validateRequired(v, 'Por favor ingresa una descripción'),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: controller.type.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'Auto-asignado',
                      child: Text('Auto-asignado'),
                    ),
                    DropdownMenuItem(
                      value: 'Aleatorio',
                      child: Text('Aleatorio'),
                    ),
                  ],
                  onChanged: controller.setType,
                  validator: controller.validateType,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.capacityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Capacidad',
                    hintText: 'Número de participantes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: controller.validateCapacity,
                ),
                const SizedBox(height: 32),
                if (controller.error.value != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.error.value!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submit(_formKey, context),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Actualizar Categoría'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
