import 'package:flutter/material.dart';
import 'package:flutter_application/app.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar GetStorage para el manejo de tokens
  await GetStorage.init();

  runApp(const MyApp());
}
