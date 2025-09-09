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


  Future<int> joinCourseByCode({required int studentId, required String courseCode}) async {
    final db = await database;
    return await db.transaction<int>((txn) async {
      // 1) Resolver curso por código
      final courseRows = await txn.query(
        'curso',
        columns: ['id', 'profesor_id'],
        where: 'codigo = ?',
        whereArgs: [courseCode],
        limit: 1,
      );
      if (courseRows.isEmpty) {
        throw Exception('Código de curso inválido');
      }
      final int courseId = courseRows.first['id'] as int;
      final int profesorId = courseRows.first['profesor_id'] as int;

      // 2) Bloquear si es el profesor del curso
      if (studentId == profesorId) {
        throw Exception('Ya es profesor de este curso');
      }

      // 3) Bloquear si ya está inscrito como estudiante
      // EXISTS en SQL (opcional con rawQuery) o COUNT con helper
      final existsRes = await txn.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM estudiante_curso WHERE estudiante_id = ? AND curso_id = ?)',
        [studentId, courseId],
      );
      final alreadyEnrolled = Sqflite.firstIntValue(existsRes) == 1;
      if (alreadyEnrolled) {
        throw Exception('Ya está inscrito en este curso');
      }

      // 4) Insertar inscripción
      final insertedId = await txn.insert(
        'estudiante_curso',
        {
          'estudiante_id': studentId,
          'curso_id': courseId,
        },
        conflictAlgorithm: ConflictAlgorithm.abort, // no debería chocar
      );
      return insertedId;
    });
  }

}