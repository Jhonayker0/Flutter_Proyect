// theme_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  ThemeMode get themeMode => _load() ? ThemeMode.dark : ThemeMode.light;

  bool _load() => _box.read(_key) ?? false;
  Future<void> _save(bool v) => _box.write(_key, v);

  Future<void> toggleTheme() async {
    final isDark = _load();
    await _save(!isDark);
    Get.changeThemeMode(!isDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => _load();
}







