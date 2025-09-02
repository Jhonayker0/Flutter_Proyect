import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../routes.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  var obscure = true.obs;
  var rememberMe = true.obs;
  var loading = false.obs;
  var error = ''.obs;

  void toggleObscure() => obscure.value = !obscure.value;
  void toggleRememberMe(bool? v) => rememberMe.value = v ?? false;

  String? validateEmail(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa tu email';
    final emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailReg.hasMatch(text)) return 'Email no válido';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    loading.value = true;
    error.value = '';

    final success =
        await loginUseCase.execute(emailCtrl.text.trim(), passCtrl.text);

    if (success) {
      Get.offAllNamed(Routes.home);
    } else {
      error.value = 'Credenciales inválidas. Prueba demo@correo.com / 123456';
    }

    loading.value = false;
  }
}
