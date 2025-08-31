import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Perfil arriba
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Jhonayker Echeverria",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("@jhonay_ker",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Opciones de configuración
          const _SettingsOption(
            icon: Icons.person_outline,
            title: "Cuenta",
          ),
          const _SettingsOption(
            icon: Icons.history,
            title: "Actividad reciente",
          ),
          const _SettingsOption(
            icon: Icons.devices,
            title: "Dispositivos",
          ),
          const _SettingsOption(
            icon: Icons.notifications_outlined,
            title: "Notificaciones",
          ),
          const _SettingsOption(
            icon: Icons.color_lens_outlined,
            title: "Apariencia",
          ),
          const _SettingsOption(
            icon: Icons.language,
            title: "Idioma",
          ),
          const _SettingsOption(
            icon: Icons.lock_outline,
            title: "Privacidad y seguridad",
          ),
          const _SettingsOption(
            icon: Icons.storage_outlined,
            title: "Almacenamiento",
          ),
          const _SettingsOption(
            icon: Icons.logout,
            title: "Cerrar sesión",
          ),
        ],
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsOption({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          if (title == "Cerrar sesión") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title seleccionado")),
          );
        },
      ),
    );
  }
}
