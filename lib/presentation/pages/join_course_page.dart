import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/controllers/join_course_controller.dart';
import 'package:get/get.dart';

class JoinCoursePage extends GetView<JoinCourseController> {
  const JoinCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar al curso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código del curso',
                  hintText: 'Ej. ABC123',
                ),
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Ingrese el código';
                  if (v.length < 4) return 'Código demasiado corto';
                  return null;
                },
                onFieldSubmitted: (_) => controller.submit(),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final busy = controller.isLoading.value;
                return ElevatedButton(
                  onPressed: busy ? null : controller.submit,
                  child: busy
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ingresar'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
