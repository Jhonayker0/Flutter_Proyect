// presentation/pages/create_category_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_category_controller.dart';

class CreateCategoryPage extends GetView<CreateCategoryController> {
  CreateCategoryPage({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Categoría')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Obx(() => ListView(
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad',
                      hintText: 'Ingresa un número...',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.validateCapacity,
                  ),
                  const SizedBox(height: 30),
                  if (controller.error.value != null)
                    Text(controller.error.value!,
                        style: TextStyle(color: cs.error)),
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
                              horizontal: 24, vertical: 14),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear'),
                      ),
                      OutlinedButton(
                        onPressed:
                            controller.isLoading.value ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}







