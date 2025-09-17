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
