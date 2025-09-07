import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<User?> login(String email, String password) async {
    final userMap = await _service.getUserByCredentials(email, password);

    if (userMap == null) return null;
    return User.fromMap(userMap);
  }

  @override
  Future<User?> signUp(String name, String email, String password) async {
    // Normalizamos el correo
    final e = email.trim().toLowerCase();

    // Verificamos si ya existe un usuario con ese correo
    final users = await _service.getUsers();
    final exists = users.any((u) => (u['correo'] as String?)?.toLowerCase() == e);

    if (exists) return null;

    // Creamos el nuevo usuario
    final newUser = {
      'nombre': name,
      'correo': e,
      'contrasena': password,
      'imagen': null, // opcional, por si más adelante manejas imagen
    };

    final id = await _service.addUser(newUser);

    // Devolvemos el User con su id generado
    return User.fromMap({...newUser, 'id': id});
  }
}
