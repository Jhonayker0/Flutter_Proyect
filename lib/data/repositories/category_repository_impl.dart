
import 'package:flutter_application/domain/models/category.dart';
import 'package:flutter_application/domain/repositories/category_repository.dart';
import '../services/category_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService service;
  CategoryRepositoryImpl(this.service);

  @override
  Future<void> create(Category category) async {
    final dto = {
      'name': category.name,
      'description': category.description,
      'type': category.type,
      'capacity': category.capacity,
    };
    await service.postCategory(dto);
  }

  @override
  Future<List<Category>> getAll() async {
    final data = await service.getAllCategories();
    return data.map((json) => Category.fromMap(json)).toList();
  }

  @override
  Future<Category?> getById(int id) async {
    final data = await service.getCategoryById(id);
    if (data == null) return null;
    return Category.fromMap(data);
  }

  @override
  Future<void> update(Category category) async {
    if (category.id == null) throw Exception('Category ID is required for update');
    
    final dto = {
      'name': category.name,
      'description': category.description,
      'type': category.type,
      'capacity': category.capacity,
    };
    await service.updateCategory(category.id!, dto);
  }

  @override
  Future<void> delete(int id) async {
    await service.deleteCategory(id);
  }
}
