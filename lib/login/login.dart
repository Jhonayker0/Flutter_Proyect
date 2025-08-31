import 'package:flutter/material.dart';
import 'package:flutter_application/home/home.dart';
import 'package:flutter_application/login/sing_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;
  String? _error;

  Future<void> _onLogin() async {
    setState(() {
      _error = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Simulación de login (reemplaza con tu lógica / API)
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email == 'demo@correo.com' && pass == '123456') {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        _error = 'Credenciales inválidas. Prueba demo@correo.com / 123456';
      });
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TEXTO ARRIBA DEL HEADER VISUAL
                    const SizedBox(height: 18),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 26, color: Colors.black, fontFamily: 'Arial', fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Header visual
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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.network(
                              'https://img.freepik.com/premium-photo/imagen-de-un-salon-de-clases_1134706-19.jpg?w=2000',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'tucorreo@ejemplo.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final text = v?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Ingresa tu email';
                                }
                                final emailReg = RegExp(
                                    r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
                                if (!emailReg.hasMatch(text)) {
                                  return 'Email no válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  tooltip: _obscure
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',
                                ),
                              ),
                              validator: (v) {
                                final text = v ?? '';
                                if (text.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (text.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 6),

                            // opciones
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                ),
                                const Text('Recordarme'),
                                const Spacer(),
                                TextButton(
                                  onPressed: _loading ? null : () {},
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ],
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18, color: cs.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: cs.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: _loading ? null : _onLogin,
                                child: _loading
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
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿No tienes cuenta?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                                    );  
                                  },
                                  child: const Text('Crear una cuenta'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider social
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('o continúa con'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loading ? null : () {},
                              icon: const Icon(Icons.g_mobiledata),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}