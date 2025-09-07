import '../datasources/database.dart'; 

class AuthService {
  final DatabaseService _dbService = DatabaseService();

  /// Obtiene todos los usuarios
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await _dbService.database;
    return await db.query('persona');
  }

  /// Obtiene un usuario por email y contraseña
  Future<Map<String, dynamic>?> getUserByCredentials(String email, String password) async {
    final db = await _dbService.database;
    final res = await db.query(
      'persona',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [email.trim().toLowerCase(), password],
    );

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  /// Agrega un nuevo usuario
  Future<int> addUser(Map<String, dynamic> user) async {
    final db = await _dbService.database;
    return await db.insert('persona', user);
  }

  /// Elimina un usuario
  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return await db.delete('persona', where: 'id = ?', whereArgs: [id]);
  }

  /// Actualiza un usuario
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await _dbService.database;
    return await db.update(
      'persona',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }
}
