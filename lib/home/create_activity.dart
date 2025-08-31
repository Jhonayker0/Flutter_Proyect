import 'package:flutter/material.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
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

  void _clearAll() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _deadline = null;
      _category = null;
    });
  }

  void _createActivity() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividad creada!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Actividad"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Activity name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Actividad",
                  hintText: "Escribe aquí...",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Por favor ingresa un nombre" : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  hintText: "Escribe aquí...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Deadline
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
                  child: const Text("Seleccionar"),
                ),
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Categoría",
                  border: OutlineInputBorder(),
                ),
                value: _category,
                items: const [
                  DropdownMenuItem(value: "Category 1", child: Text("Categoría 1")),
                  DropdownMenuItem(value: "Category 2", child: Text("Categoría 2")),
                  DropdownMenuItem(value: "Category 3", child: Text("Categoría 3")),
                ],
                onChanged: (v) => setState(() => _category = v),
                validator: (v) =>
                    v == null ? "Por favor selecciona una categoría" : null,
              ),
              const SizedBox(height: 30),
                            // Adjuntar Archivo
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_file), // Cambia el ícono
                label: const Text("Adjuntar Archivo"), // Cambia el texto
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: cs.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _createActivity,
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
