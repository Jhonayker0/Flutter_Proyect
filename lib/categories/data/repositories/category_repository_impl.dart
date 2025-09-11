
import 'package:flutter_application/categories/domain/models/category.dart';
import 'package:flutter_application/categories/domain/repositories/category_repository.dart';
import '../services/category_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService service;
  CategoryRepositoryImpl(this.service);

  // Normaliza 'Type' del dominio a los valores de la DB
  String _normalizeType(String type) {
    final t = type.trim().toLowerCase();
    if (t.startsWith('ale')) return 'aleatorio';
    if (t.startsWith('auto')) return 'auto-asignado';
    // fallback conservador
    return t;
  }

  // Mapea fila DB -> dominio
  Category _fromDb(Map<String, Object?> row) {
    return Category(
      id: row['id'] as int?,
      name: (row['nombre'] as String?) ?? '',
      // Si la columna 'descripcion' no existe en tu tabla, deja vacío u opcional
      description: (row['descripcion'] as String?) ?? '',
      type: (row['tipo'] as String?) ?? '',
      capacity: row['capacidad'] as int,
      // Asegúrate de que Category tenga courseId en el dominio
      courseId: (row['curso_id'] as num).toInt(),
    );
  }


  @override
  Future<int> create(Category category) async {
    final id = await service.postCategory(
      nombre: category.name,
      tipo: _normalizeType(category.type),
      descripcion: category.description,
      capacidad: category.capacity,
      cursoId: category.courseId, 
    );
    return id;
  }

  @override
  Future<List<Category>> getAll(int courseId) async {
    final rows = await service.getAllCategoriesByCourse(courseId);
    return rows.map(_fromDb).toList();
  }

  @override
  Future<Category?> getById(int id) async {
    final row = await service.getCategoryById(id);
    return row == null ? null : _fromDb(row);
  }

  @override
  Future<void> update(Category category) async {
    if (category.id == null) {
      throw Exception('Category ID is required for update');
    }
    await service.updateCategory(
      category.id!,
      nombre: category.name,
      tipo: _normalizeType(category.type),
      capacidad: category.capacity,
      // Si agregas 'descripcion' a la tabla, pásala aquí y en el servicio
    );
  }

  @override
  Future<void> delete(int id) async {
    await service.deleteCategory(id);
  }

  // Extensiones útiles para la UI

  @override
  Future<List<GroupSummary>> getGroupsByCategory(int categoriaId) async {
    final rows = await service.getGroupsByCategory(categoriaId);
    return rows.map((m) => GroupSummary(
      id: (m['id'] as num).toInt(),
      name: (m['nombre'] as String?) ?? '',
      capacity: m['capacidad'] as int?,
      members: (m['miembros'] as num?)?.toInt() ?? 0,
    )).toList();
  }

  // Unir estudiante a grupo (valida capacidad y unicidad en la categoría)
  Future<int> addStudentToGroup({
    required int groupId,
    required int studentId,
  }) {
    return service.addStudentToGroup(
      grupoId: groupId,
      estudianteId: studentId,
    );
  }
  
  @override
  Future<List<Member>> getMembersByGroup(int groupId, int categoryId) async {
    final rows = await service.getMembersByGroupRaw(groupId, categoryId);
    return rows.map((m) => Member(
      id: (m['id'] as num).toInt(),
      name: (m['name'] as String?) ?? '',
      email: m['email'] as String?,
    )).toList();
  }
  
  @override
  Future<void> joinGroup(int studentId, int groupId) async {
     await service.joinGroup(studentId, groupId);
  }

  @override
  Future<void> assignStudentToGroup(int studentId, int groupId, int categoryId) async {
    await service.assignStudentToGroup(studentId, groupId, categoryId);
  }

  @override
  Future<void> removeStudentFromGroup(int studentId, int categoryId) async {
    await service.removeStudentFromGroup(studentId, categoryId);
  }

  @override
  Future<List<Member>> getUnassignedStudents(int courseId, int categoryId) async {
    return await service.getUnassignedStudents(courseId, categoryId);
  }
}

// Modelo auxiliar para la UI de grupos
class GroupSummary {
  final int id;
  final String name;
  final int? capacity;
  final int members;
  GroupSummary({
    required this.id,
    required this.name,
    this.capacity,
    required this.members,
  });
  
}







