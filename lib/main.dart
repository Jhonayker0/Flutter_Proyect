import 'package:flutter/material.dart';
import 'package:flutter_application/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login UI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x00336699)
      ),
      home: const LoginPage(),
    );
  }
}

