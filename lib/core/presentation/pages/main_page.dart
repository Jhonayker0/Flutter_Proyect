import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_application/courses/presentation/pages/courses_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Explorar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.asset(
              'assets/profile.jpg',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen no se puede cargar, mostrar el icono por defecto
                return const Icon(
                  Icons.account_circle,
                  size: 32,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "logout") {
                authController.logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text("Cerrar sesión"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const CoursesPage(),
    );
  }
}
