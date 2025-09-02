import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      const _SettingsOption(icon: Icons.person_outline, title: "Cuenta"),
      const _SettingsOption(icon: Icons.history, title: "Actividad reciente"),
      const _SettingsOption(icon: Icons.devices, title: "Dispositivos"),
      const _SettingsOption(icon: Icons.notifications_outlined, title: "Notificaciones"),
      const _SettingsOption(icon: Icons.color_lens_outlined, title: "Apariencia"),
      const _SettingsOption(icon: Icons.language, title: "Idioma"),
      const _SettingsOption(icon: Icons.lock_outline, title: "Privacidad y seguridad"),
      const _SettingsOption(icon: Icons.storage_outlined, title: "Almacenamiento"),
      const _SettingsOption(icon: Icons.logout, title: "Cerrar sesión"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Perfil arriba
          Row(
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jhonayker Echeverria",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("@jhonay_ker", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Opciones con callback al controller
          ...options.map(
            (option) => option.copyWith(
              onTap: () => controller.selectOption(option.title),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget de opción
class _SettingsOption extends GetView<SettingsController> {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsOption({required this.icon, required this.title, this.onTap});

  _SettingsOption copyWith({VoidCallback? onTap}) {
    return _SettingsOption(icon: icon, title: title, onTap: onTap ?? this.onTap);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final trailing = title == 'Apariencia'
        // Opción sin Obx; si se usa Rx en el controller, envolver en Obx
        ? Switch(
            value: controller.isDark, // o Get.isDarkMode
            onChanged: (_) => controller.toggleTheme(),
          )
        : const Icon(Icons.arrow_forward_ios, size: 18);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(title),
        trailing: trailing,
        onTap: () {
          if (title == 'Apariencia') {
            controller.toggleTheme(); // alterna con tap
            return;
          }
          onTap?.call(); // delega al callback general
        },
      ),
    );
  }
}

