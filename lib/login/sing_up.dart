import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _agree = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  void _createAccount() {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos y condiciones")),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
  }

  Widget _buildField({
    required String label,
    required String example,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: suffix,
          ),
          validator: validator,
        ),
        const SizedBox(height: 4),
        Text(
          "Ej: $example",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cuenta"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Crea una cuenta para empezar",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Nombre
              _buildField(
                label: "Nombre",
                example: "Juan Pérez",
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa tu nombre" : null,
              ),

              // Email
              _buildField(
                label: "Correo electrónico",
                example: "ejemplo@email.com",
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Ingresa tu correo";
                  }
                  final emailReg =
                      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
                  if (!emailReg.hasMatch(v)) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),

              // Contraseña
              _buildField(
                label: "Contraseña",
                example: "Mínimo 6 caracteres",
                controller: _passCtrl,
                obscure: _obscure1,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscure1 = !_obscure1),
                  icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Ingresa una contraseña";
                  }
                  if (v.length < 6) {
                    return "Mínimo 6 caracteres";
                  }
                  return null;
                },
              ),

              // Confirmar contraseña
              _buildField(
                label: "Confirmar contraseña",
                example: "Repite tu contraseña",
                controller: _confirmPassCtrl,
                obscure: _obscure2,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscure2 = !_obscure2),
                  icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Confirma tu contraseña";
                  }
                  if (v != _passCtrl.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),

              // Checkbox términos
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (v) =>
                        setState(() => _agree = v ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text("He leído y acepto los "),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Términos y condiciones")),
                            );
                          },
                          child: Text(
                            "Términos y Condiciones",
                            style: TextStyle(
                              color: cs.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(" y la "),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Política de privacidad")),
                            );
                          },
                          child: Text(
                            "Política de Privacidad",
                            style: TextStyle(
                              color: cs.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botón crear cuenta
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createAccount,          
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: const Text("Crear cuenta"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
