import 'package:flutter_application/categories/domain/models/category.dart';

abstract class CategoryRepository {
  Future<void> create(Category category);
  Future<List<Category>> getAll(String courseId);
  Future<Category?> getById(String id);
  Future<void> update(Category category);
  Future<void> delete(String id);
}
