import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE persona (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            correo TEXT UNIQUE NOT NULL,
            contrasena TEXT NOT NULL,
            imagen TEXT
          )
        ''');

        await db.insert('persona', {
          'nombre': 'usuario1',
          'correo': 'a@a.com',
          'contrasena': '123456'});

        await db.insert('persona', {
          'nombre': 'usuario2',
          'correo': 'b@a.com',
          'contrasena': '123456'});

        await db.insert('persona', {
          'nombre': 'usuario3',
          'correo': 'c@a.com',
          'contrasena': '123456'});

        await db.execute('''
          CREATE TABLE curso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre_asignatura TEXT NOT NULL,
            descripcion TEXT,
            profesor_id INTEGER NOT NULL,
            codigo TEXT,
            FOREIGN KEY (profesor_id) REFERENCES persona(id)
          )
        ''');

        await db.insert('curso', {
          'nombre_asignatura': 'curso1',
          'descripcion': 'Curso de prueba',
          'profesor_id': 1,
          'codigo': '123456'});

        await db.execute('''
          CREATE TABLE categoria (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL CHECK (tipo IN ('aleatorio', 'auto-asignado')),
            capacidad INTEGER,
            curso_id INTEGER NOT NULL,
            FOREIGN KEY (curso_id) REFERENCES curso(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE actividad (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria_id INTEGER NOT NULL,
            fecha_entrega TEXT,
            fecha_publicacion TEXT,
            FOREIGN KEY (categoria_id) REFERENCES categoria(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE evaluacion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            actividad_id INTEGER NOT NULL,
            tiempo_pantalla INTEGER,
            visibilidad TEXT NOT NULL CHECK (visibilidad IN ('Public', 'Private')),
            FOREIGN KEY (actividad_id) REFERENCES actividad(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE criterio (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descripcion TEXT NOT NULL,
            puntaje INTEGER NOT NULL,
            evaluacion_id INTEGER NOT NULL,
            FOREIGN KEY (evaluacion_id) REFERENCES evaluacion(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE estudiante_curso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            estudiante_id INTEGER NOT NULL,
            curso_id INTEGER NOT NULL,
            FOREIGN KEY (estudiante_id) REFERENCES persona(id),
            FOREIGN KEY (curso_id) REFERENCES curso(id)
          )
        ''');

        await db.insert('estudiante_curso', {
          'estudiante_id': 2,
          'curso_id': 1});
      },
    );
  }
}
