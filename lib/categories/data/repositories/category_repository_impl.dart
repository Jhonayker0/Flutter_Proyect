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
    if (t.startsWith('ele')) return 'eleccion';
    return t;
  }

  // Mapea fila DB -> dominio
  Category _fromDb(Map<String, dynamic> row) {
    return Category(
      id: row['id']?.toString(),
      name: (row['name'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      type: (row['type'] as String?) ?? '',
      courseId: row['course_id']?.toString() ?? '',
      capacity: (row['capacity'] as int?) ?? 5,
    );
  }

  @override
  Future<void> create(Category category) async {
    await service.postCategory(
      nombre: category.name,
      tipo: _normalizeType(category.type),
      descripcion: category.description,
      cursoId: category.courseId.toString(),
      capacity: category.capacity, // Agregar capacidad
    );
  }

  @override
  Future<List<Category>> getAll(String courseId) async {
    final rows = await service.getAllCategoriesByCourse(courseId);
    return rows.map(_fromDb).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final row = await service.getCategoryById(id);
    return row == null ? null : _fromDb(row);
  }

  @override
  Future<void> update(Category category) async {
    if (category.id == null) {
      throw Exception('Category ID is required for update');
    }
    await service.updateCategory(
      category.id.toString(),
      nombre: category.name,
      tipo: _normalizeType(category.type),
      descripcion: category.description,
    );
  }

  @override
  Future<void> delete(String id) async {
    await service.deleteCategory(id);
  }
}
