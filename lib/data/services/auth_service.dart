import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AuthService {
  List<Map<String, dynamic>> _users = [];
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;

    try {
      final raw = await rootBundle.loadString('assets/mockup.json');
      final data = json.decode(raw);
      if (data is List) {
        _users = List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {
      _users = [];
    }

    _loaded = true;
    print(_users);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    await _load();
    return _users;
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    await _load();
    _users.add(user);
    print(_users);
  }
}
