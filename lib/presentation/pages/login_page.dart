import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../../routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final obscure = true.obs;
  final rememberMe = false.obs;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remember_email');
    final pass = prefs.getString('remember_pass');

    if (email != null && pass != null) {
      emailCtrl.text = email;
      passCtrl.text = pass;
      rememberMe.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 18),
                        const Text(
                          'Bienvenido',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Image.network(
                            'https://img.freepik.com/premium-photo/imagen-de-un-salon-de-clases_1134706-19.jpg?w=2000',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'tucorreo@ejemplo.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Ingresa tu email' : null,
                        ),
                        const SizedBox(height: 14),

                        // Password
                        Obx(() => TextFormField(
                              controller: passCtrl,
                              obscureText: obscure.value,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () => obscure.value = !obscure.value,
                                  icon: Icon(
                                    obscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
                            )),
                        const SizedBox(height: 6),

                        // Recordarme + olvidé contraseña
                        Obx(() => Row(
                              children: [
                                Checkbox(
                                  value: rememberMe.value,
                                  onChanged: (v) => rememberMe.value = v ?? false,
                                ),
                                const Text('Recordarme'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ],
                            )),

                        const SizedBox(height: 6),

                        // Error
                        Obx(() => controller.error.value != null
                            ? Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18, color: cs.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.error.value ?? '',
                                      style: TextStyle(
                                        color: cs.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox()),

                        const SizedBox(height: 12),
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) return;
                                        await controller.login(
                                          emailCtrl.text.trim(),
                                          passCtrl.text,
                                          remember: rememberMe.value,
                                        );
                                      },
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar sesión',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            )),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: () => Get.toNamed(Routes.signup),
                              child: const Text('Crear una cuenta'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const Text("o continúa con"),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Google'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
