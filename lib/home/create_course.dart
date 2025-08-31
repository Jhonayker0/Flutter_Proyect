import 'package:flutter/material.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  String? _category;

  void _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }
  void _createCourse() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Curso creado!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Curso"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre del curso
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre del curso",
                  hintText: "Escribe el nombre aquí...",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Por favor ingresa un nombre" : null,
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  hintText: "Escribe la descripción aquí...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty
                    ? "Por favor ingresa una descripción"
                    : null,
              ),
              const SizedBox(height: 20),

              // Fecha límite
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text("Fecha límite"),
                subtitle: Text(
                  _deadline != null
                      ? "${_deadline!.day}/${_deadline!.month}/${_deadline!.year}"
                      : "Sin fecha seleccionada",
                ),
                trailing: TextButton(
                  onPressed: _pickDeadline,
                  child: const Text("Seleccionar fecha"),
                ),
              ),
              const SizedBox(height: 20),
              // Añadir imagen
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Añadir imagen"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: cs.primary),
                ),
              ),
              const SizedBox(height: 20),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _createCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text("Crear"),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text("Cancelar"),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}