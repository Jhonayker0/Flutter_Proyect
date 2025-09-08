import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CourseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    return await openDatabase(path);
  }

  /// Crear curso
  Future<int> postCourse(Map<String, dynamic> json) async {
    final db = await database;
    return await db.insert('curso', json);
  }

  /// Obtener todos los cursos
  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return await db.query('curso');
  }

  /// Obtener cursos donde el usuario es profesor
  Future<List<Map<String, dynamic>>> getCoursesByProfesor(int profesorId) async {
    final db = await database;
    return await db.query(
      'curso',
      where: 'profesor_id = ?',
      whereArgs: [profesorId],
    );
  }

  /// Obtener cursos donde el usuario es estudiante
  Future<List<Map<String, dynamic>>> getCoursesByEstudiante(int estudianteId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT c.*
      FROM curso c
      INNER JOIN estudiante_curso ec ON c.id = ec.curso_id
      WHERE ec.estudiante_id = ?
    ''', [estudianteId]);
  }

  /// Borrar curso
  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete(
      'curso',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByCourse(int courseId) async {
  final db = await database;
  return await db.rawQuery('''
    SELECT p.id, p.nombre, p.correo, p.imagen
    FROM persona p
    INNER JOIN estudiante_curso ec ON p.id = ec.estudiante_id
    WHERE ec.curso_id = ?
  ''', [courseId]);
}
}
