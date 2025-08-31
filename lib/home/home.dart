import 'package:flutter/material.dart';
import 'package:flutter_application/home/create_activity.dart';
import 'package:flutter_application/home/create_category.dart';
import 'package:flutter_application/home/create_course.dart';
import 'package:flutter_application/login/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto quita la flecha de retroceso
        title: const Text("Main Page"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          // Botón de configuración con menú desplegable
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == "logout") {
                // Acción de cerrar sesión
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$value seleccionado")),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "perfil",
                child: Text("Perfil"),
              ),
              const PopupMenuItem(
                value: "notificaciones",
                child: Text("Notificaciones"),
              ),
              const PopupMenuItem(
                value: "logout",
                child: Text("Cerrar sesión"),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil / encabezado
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Alicia",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // Barra de búsqueda + filtro
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search courses...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Your courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Lista de cursos
            Expanded(
              child: ListView(
                children: const [
                  CourseCard(title: "Alicia´s Course", role: "Student"),
                  CourseCard(title: "UI/UX", role: "Student"),
                  CourseCard(title: "DATA´S STRUCTURE II", role: "Student"),
                  CourseCard(title: "Mobile´s course", role: "Professor"),
                  CourseCard(title: "Mobile’s course", role: "Professor"),
                ],
              ),
            ),
          ],
        ),
      ),
      // Botón flotante Crear curso
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
            );
        },
        label: const Text("Crear curso"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String role;

  const CourseCard({super.key, required this.title, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: const Icon(Icons.book, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Role: $role"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // Navegar a detalle
        },
      ),
    );
  }
}