import 'package:flutter/material.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String? _tipo;

  void _clearAll() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _descCtrl.clear();
    _capacityCtrl.clear();
    setState(() {
      _tipo = null;
    });
  }

  void _createCategory() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categoría creada!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Categoría"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Categoría",
                  hintText: "Escribe aquí...",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? "Por favor ingresa un nombre"
                    : null,
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  hintText: "Escribe aquí...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty
                    ? "Por favor ingresa una descripción"
                    : null,
              ),
              const SizedBox(height: 20),

              // Tipo
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Tipo",
                  border: OutlineInputBorder(),
                ),
                value: _tipo,
                items: const [
                  DropdownMenuItem(
                      value: "Auto-asignado", child: Text("Auto-asignado")),
                  DropdownMenuItem(value: "Aleatorio", child: Text("Aleatorio")),
                ],
                onChanged: (v) => setState(() => _tipo = v),
                validator: (v) => v == null ? "Selecciona un tipo" : null,
              ),
              const SizedBox(height: 20),

              // Capacidad
              TextFormField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacidad",
                  hintText: "Ingresa un número...",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingresa la capacidad";
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) {
                    return "Debe ser un número mayor a 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _createCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text("Crear"),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
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
