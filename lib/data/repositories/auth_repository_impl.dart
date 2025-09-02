import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<User?> login(String email, String password) async {
    final users = await _service.getUsers();
    final e = email.trim().toLowerCase();
    final p = password;

    final userMap = users.firstWhere(
      (u) =>
          (u['email'] as String?)?.toLowerCase() == e &&
          (u['password'] as String?) == p,
      orElse: () => {},
    );

    if (userMap.isEmpty) return null;
    return User.fromMap(userMap);
  }

  @override
  Future<User?> signUp(String name, String email, String password) async {
    final users = await _service.getUsers();
    final e = email.trim().toLowerCase();
    final exists = users.any((u) => (u['email'] as String?)?.toLowerCase() == e);
    if (exists) return null;

    final newUser = {
      'id': users.length + 1,
      'name': name,
      'email': e,
      'password': password,
    };
    await _service.addUser(newUser);
    return User.fromMap(newUser);
  }
}
