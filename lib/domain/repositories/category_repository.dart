import 'package:flutter_application/domain/models/category.dart';

abstract class CategoryRepository {
  Future<void> create(Category category);
  Future<List<Category>> getAll();
  Future<Category?> getById(int id);
  Future<void> update(Category category);
  Future<void> delete(int id);
}
