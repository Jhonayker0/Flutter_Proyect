import 'package:flutter_application/data/datasources/database.dart';
import 'package:sqflite/sqflite.dart';

class CategoryService {
  final DatabaseService _dbService = DatabaseService();
  // Crear categoría y sus grupos "Grupo 1..G" según capacidad y estudiantes del curso
  Future<int> postCategory({
    required String nombre,
    required String tipo, // 'aleatorio' | 'auto-asignado'
    required int? capacidad, // X por grupo
    required int cursoId,
    required String? descripcion,
  }) async {
    final db = await _dbService.database;
    return await db.transaction<int>((txn) async {
      // 1) Crear categoría
      final categoriaId = await txn.insert('categoria', {
        'nombre': nombre,
        'tipo': tipo,
        'descripcion': descripcion,
        'capacidad': capacidad,
        'curso_id': cursoId,
      });

      // 2) Leer estudiantes del curso
      final rows = await txn.rawQuery(
        'SELECT estudiante_id FROM estudiante_curso WHERE curso_id = ?',
        [cursoId],
      );
      final students = rows
          .map((m) => (m['estudiante_id'] as num).toInt())
          .toList();

      // 3) Crear grupos según capacidad
      final x = (capacidad ?? 0) <= 0 ? 0 : capacidad!;
      final n = students.length;
      int g = 1;
      if (x > 0 && n > 0) {
        // ceil(n/x) sin ceil nativo
        g = (n + x - 1) ~/ x;
      }

      // Crear y guardar ids de grupos
      final groupIds = <int>[];
      for (int i = 1; i <= g; i++) {
        final gid = await txn.insert('grupo', {
          'categoria_id': categoriaId,
          'nombre': 'Grupo $i',
          'capacidad': capacidad,
        });
        groupIds.add(gid);
      }

      // 4) Si es aleatorio, asignar estudiantes ahora
      if (tipo == 'aleatorio' && n > 0 && groupIds.isNotEmpty) {
        students.shuffle(); // barajar en memoria
        // Round-robin con límite de X por grupo
        final counters = List<int>.filled(groupIds.length, 0);
        final batch = txn.batch();
        int gi = 0;
        for (final sid in students) {
          // Si hay capacidad X, saltar grupos llenos
          int attempts = 0;
          while (attempts < groupIds.length && x > 0 && counters[gi] >= x) {
            gi = (gi + 1) % groupIds.length;
            attempts++;
          }
          // Insertar si el grupo elegido no está lleno
          if (x == 0 || counters[gi] < x) {
            batch.insert('categoria_estudiante', {
              'grupo_id': groupIds[gi],
              'estudiante_id': sid,
            });
            counters[gi] += 1;
            gi = (gi + 1) % groupIds.length;
          }
        }
        await batch.commit(noResult: true);
      }

      return categoriaId;
    });
  }

  // Listado de categorías (básico)
  Future<List<Map<String, Object?>>> getAllCategoriesByCourse(int courseId) async {
    final db = await _dbService.database;
    return await db.query(
      'categoria',
      where: 'curso_id = ?',
      whereArgs: [courseId],
      orderBy: 'id DESC',
    );
  }
  // Obtener una categoría por id
  Future<Map<String, Object?>?> getCategoryById(int id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      'categoria',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  // Actualizar categoría (no re-calcula grupos aquí; opcional)
  Future<int> updateCategory(
    int id, {
    required String nombre,
    required String tipo,
    required int? capacidad,
  }) async {
    final db = await _dbService.database;
    return await db.update(
      'categoria',
      {'nombre': nombre, 'tipo': tipo, 'capacidad': capacidad},
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Eliminar categoría y sus grupos/membresías
  Future<void> deleteCategory(int id) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      // Borrar membresías de los grupos de esta categoría
      final groupIds = await txn.query(
        'grupo',
        columns: ['id'],
        where: 'categoria_id = ?',
        whereArgs: [id],
      );
      final batch = txn.batch();
      for (final g in groupIds) {
        batch.delete(
          'categoria_estudiante',
          where: 'grupo_id = ?',
          whereArgs: [g['id']],
        );
      }
      await batch.commit(noResult: true);

      // Borrar grupos
      await txn.delete('grupo', where: 'categoria_id = ?', whereArgs: [id]);

      // Borrar categoría
      await txn.delete('categoria', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Listar grupos de una categoría con conteo de miembros
  Future<List<Map<String, Object?>>> getGroupsByCategory(
    int categoriaId,
  ) async {
    final db = await _dbService.database;
    return await db.rawQuery(
      '''
      SELECT g.id, g.nombre, g.capacidad,
             (SELECT COUNT(*) FROM categoria_estudiante ce WHERE ce.grupo_id = g.id) AS miembros
      FROM grupo g
      WHERE g.categoria_id = ?
      ORDER BY g.id
    ''',
      [categoriaId],
    );
  }

  // Ingresar estudiante a grupo por id, validando capacidad y unicidad en la categoría
  Future<int> addStudentToGroup({
    required int grupoId,
    required int estudianteId,
  }) async {
    final db = await _dbService.database;
    return await db.transaction<int>((txn) async {
      // 1) Resolver categoría y capacidad efectiva
      final gRows = await txn.rawQuery(
        '''
        SELECT g.categoria_id AS categoria_id,
               COALESCE(g.capacidad, c.capacidad) AS cap
        FROM grupo g
        JOIN categoria c ON c.id = g.categoria_id
        WHERE g.id = ?
        LIMIT 1
      ''',
        [grupoId],
      );
      if (gRows.isEmpty) {
        throw Exception('Grupo inexistente');
      }
      final int categoriaId = (gRows.first['categoria_id'] as num).toInt();
      final int? cap = gRows.first['cap'] as int?;

      // 2) Bloquear si el estudiante ya pertenece a algún grupo de esta categoría
      final existsAny = await txn.rawQuery(
        'SELECT COUNT(*) FROM categoria_estudiante WHERE categoria_id = ? AND estudiante_id = ?',
        [categoriaId, estudianteId],
      );
      final alreadyInCategory = (Sqflite.firstIntValue(existsAny) ?? 0) > 0;
      if (alreadyInCategory) {
        throw Exception(
          'El estudiante ya pertenece a un grupo de esta categoría',
        );
      }

      // 3) Validar capacidad del grupo (si definida)
      if (cap != null) {
        final cur = await txn.rawQuery(
          'SELECT COUNT(*) FROM categoria_estudiante WHERE grupo_id = ?',
          [grupoId],
        );
        final currentCount = Sqflite.firstIntValue(cur) ?? 0;
        if (currentCount >= cap) {
          throw Exception('Grupo lleno');
        }
      }

      // 4) Insertar membresía (respetando UNIQUE si existe)
      final id = await txn.insert('categoria_estudiante', {
        'grupo_id': grupoId,
        'categoria_id': categoriaId,
        'estudiante_id': estudianteId,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return id;
    });
  }

  Future<List<Map<String, Object?>>> getMembersByGroupRaw(
    int groupId,
    int categoryId,
  ) async {
    final db = await _dbService.database;
    return db.rawQuery(
      '''
      SELECT e.id      AS id,
            e.nombre  AS name,
            e.correo  AS email
      FROM categoria_estudiante ce
      JOIN persona e ON e.id = ce.estudiante_id
      JOIN grupo g ON ce.grupo_id = g.id
      WHERE ce.grupo_id = ? 
        AND g.categoria_id = ?
      ORDER BY e.nombre COLLATE NOCASE
    ''',
      [groupId, categoryId],
    );
  }
  
  Future<int> joinGroup(int studentId, int groupId) async {
    final db = await _dbService.database;
    print("llegue");
    return await db.insert('categoria_estudiante', {
      'grupo_id': groupId,
      'estudiante_id': studentId,
    });
  }
}
