import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  List<Map<String, dynamic>> _users = [];
  bool _loaded = false;
  AuthRepositoryImpl();

  /// Carga usuarios de assets/mock_users.json + agrega un usuario demo por defecto.
  Future<void> _load() async {
    if (_loaded) return;

    try {
      final raw = await rootBundle.loadString('assets/mock_users.json');
      final data = json.decode(raw);
      if (data is List) {
        _users = List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {
      // Si no existe el asset o está mal, seguimos con lista vacía.
      _users = [];
    }

    // Usuario demo para pruebas
    final demoExists = _users.any((u) =>
        (u['email'] as String?)?.toLowerCase() == 'demo@correo.com');
    if (!demoExists) {
      _users.add({
        'id': 1,
        'name': 'Demo',
        'email': 'demo@correo.com',
        'password': '123456',
      });
    }

    _loaded = true;
  }

  @override
  Future<bool> login(String email, String password) async {
    await _load();
    final e = email.trim().toLowerCase();
    final p = password;
    final user = _users.firstWhere(
      (u) =>
          (u['email'] as String?)?.toLowerCase() == e &&
          (u['password'] as String?) == p,
      orElse: () => {},
    );
    return user.isNotEmpty;
  }

  // Mock: no persiste en archivo (si quieres persistencia real, luego te paso la versión con path_provider)
  @override
  Future<bool> signUp(String name, String email, String password) async {
    await _load();
    final e = email.trim().toLowerCase();
    final exists =
        _users.any((u) => (u['email'] as String?)?.toLowerCase() == e);
    if (exists) return false;

    _users.add({
      'id': _users.length + 1,
      'name': name,
      'email': e,
      'password': password,
    });
    return true;
  }
}
